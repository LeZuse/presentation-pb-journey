// https://chat.openai.com/share/f067b90c-7e8b-4d23-99e2-e7c61df5e663

const axios = require('axios');

const token = 'token'; // Replace with your token
const orgName = 'productboard'; // Replace with the organization's name

const getRepos = async (page = 1) => {
  const url = `https://api.github.com/orgs/${orgName}/repos?per_page=100&page=${page}`;
  const headers = {
    'Authorization': `token ${token}`,
    'Accept': 'application/vnd.github.v3+json',
  };

  try {
    const response = await axios.get(url, { headers });
    return response.data;
  } catch (error) {
    console.error(error);
    return [];
  }
};

const getAllRepos = async () => {
  let page = 1;
  let repos = [];
  let batch;

  do {
    batch = await getRepos(page);
    repos = repos.concat(batch);
    page += 1;
  } while (batch.length > 0);

  return repos;
};

const main = async () => {
  const repos = await getAllRepos();

  // Object to store the count of repositories created per year per language
  const summary = {};
  const cumulativeLanguages = {};

  let grandCumulativeTotal = 0;

  repos.forEach((repo) => {
    // Skip archived repositories or forks or repositories containing "satismeter"
    if (repo.archived || repo.fork || repo.name.includes('satismeter')) return;

    const year = new Date(repo.created_at).getFullYear();
    const language = repo.language || 'Unknown';

    summary[year] = summary[year] || {};
    summary[year][language] = summary[year][language] || { count: 0, names: [] };
    summary[year][language].count += 1;
    summary[year][language].names.push(repo.name);
  });

  console.log("Cumulative summary of repositories created per year per language (excluding archived and forks):");
  Object.keys(summary).sort().forEach((year) => {
    console.log(`\n${year}:`);
    let yearlyCumulativeTotal = 0; // Total count for the current year
    Object.keys(summary[year]).sort().forEach((language) => {
      cumulativeLanguages[language] = (cumulativeLanguages[language] || 0) + summary[year][language].count;
      yearlyCumulativeTotal += summary[year][language].count;
      console.log(`  ${language}: ${summary[year][language].count} repositories (Cumulative: ${cumulativeLanguages[language]})`);
      console.log(`    Repositories: ${summary[year][language].names.join(', ')}`);
    });
    grandCumulativeTotal += yearlyCumulativeTotal;
    console.log(`  Total for ${year}: ${yearlyCumulativeTotal} repositories`);
    console.log(`  Cumulative Total up to ${year}: ${grandCumulativeTotal} repositories`);
  });
  console.log(`\nTotal Cumulative Count: ${grandCumulativeTotal} repositories`);
};

main();
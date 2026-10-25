const couch = 'http://127.0.0.1:5984';
const headers = { 'Authorization': 'Basic ' + btoa('admin:123456'), 'Content-Type': 'application/json' };

const years = {
  '1': 1977, '2': 1994, '3': 1999, '4': 1941, '6': 1997, '25': 2000, '75': 1972,
  '110': 1993, '117': 1979, '168': 1999, '190': 1997, '195': 1999, '230': 1994
};

async function addYears(database, prefix) {
  const docs = [];
  for (const id in years) {
    const response = await fetch(couch + '/' + database + '/' + prefix + id, { headers: headers });
    const movie = await response.json();
    movie.year = years[id];
    docs.push(movie);
  }

  const response = await fetch(couch + '/' + database + '/_bulk_docs', {
    method: 'POST',
    headers: headers,
    body: JSON.stringify({ docs: docs })
  });
  const result = await response.json();
  console.log(database + ': added year to ' + result.length + ' movies');
}

await addYears('movies_a', '');
await addYears('movies_b', 'movie_');

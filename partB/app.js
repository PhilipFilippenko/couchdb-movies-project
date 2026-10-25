var localDB = new PouchDB('movies_local');
var remoteDB = new PouchDB('http://127.0.0.1:5984/movies_a', {
  auth: { username: 'admin', password: '123456' }
});

var sync = null;
var isOnline = true;

function addLog(text) {
  var log = document.getElementById('log');
  var time = new Date().toLocaleTimeString();
  log.textContent = time + '  ' + text + '\n' + log.textContent;
}

function setStatus(text) {
  document.getElementById('status').textContent = text;
}

function startSync() {
  setStatus('connecting...');
  sync = localDB.sync(remoteDB, { live: true, retry: true });

  sync.on('change', function (info) {
    var docs = info.change.docs;
    var names = [];
    for (var i = 0; i < docs.length && i < 3; i++) {
      if (docs[i]._deleted) {
        names.push(docs[i]._id + ' (deleted)');
      } else {
        names.push(docs[i].title);
      }
    }
    addLog(info.direction + ' ' + docs.length + ' docs: ' + names.join(', '));
    showMovies();
  });

  sync.on('active', function () {
    setStatus('syncing...');
  });

  sync.on('paused', function (err) {
    if (err) {
      setStatus('cannot reach server');
    } else {
      setStatus('online');
    }
  });

  sync.on('error', function (err) {
    addLog('error: ' + err);
  });

  addLog('sync started');
}

function stopSync() {
  sync.cancel();
  setStatus('offline');
  addLog('sync stopped, working offline');
}

document.getElementById('toggle').onclick = function () {
  if (isOnline) {
    stopSync();
    isOnline = false;
    this.textContent = 'Go online';
  } else {
    startSync();
    isOnline = true;
    this.textContent = 'Go offline';
  }
};

function toList(text) {
  var result = [];
  var parts = text.split(',');
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].trim() != '') {
      result.push(parts[i].trim());
    }
  }
  return result;
}

document.getElementById('save').onclick = async function () {
  var movie = {
    title: document.getElementById('title').value,
    actors: toList(document.getElementById('actors').value),
    genres: toList(document.getElementById('genres').value)
  };
  var id = document.getElementById('id').value;

  if (id == '') {
    var result = await localDB.post(movie);
    addLog('created ' + movie.title + ' (id ' + result.id + ')');
  } else {
    movie._id = id;
    movie._rev = document.getElementById('rev').value;
    await localDB.put(movie);
    addLog('updated ' + movie.title);
  }

  clearForm();
  showMovies();
};

async function editMovie(id) {
  var movie = await localDB.get(id);
  document.getElementById('id').value = movie._id;
  document.getElementById('rev').value = movie._rev;
  document.getElementById('title').value = movie.title;
  document.getElementById('actors').value = (movie.actors || []).join(', ');
  document.getElementById('genres').value = (movie.genres || []).join(', ');
  document.getElementById('formTitle').textContent = 'Edit movie ' + movie._id;
}

async function deleteMovie(id) {
  var movie = await localDB.get(id);
  if (confirm('Delete ' + movie.title + '?')) {
    await localDB.remove(movie);
    addLog('deleted ' + movie.title);
    showMovies();
  }
}

function clearForm() {
  document.getElementById('id').value = '';
  document.getElementById('rev').value = '';
  document.getElementById('title').value = '';
  document.getElementById('actors').value = '';
  document.getElementById('genres').value = '';
  document.getElementById('formTitle').textContent = 'Add movie';
}

document.getElementById('clear').onclick = clearForm;
document.getElementById('search').oninput = showMovies;

async function showMovies() {
  var result = await localDB.allDocs({ include_docs: true, conflicts: true });
  var search = document.getElementById('search').value.toLowerCase();
  var html = '';
  var shown = 0;
  var total = 0;
  var conflicts = [];

  for (var i = 0; i < result.rows.length; i++) {
    var movie = result.rows[i].doc;
    if (movie._id.startsWith('_design')) {
      continue;
    }
    total++;

    if (movie._conflicts) {
      conflicts.push(movie);
    }

    var actors = (movie.actors || []).join(', ');
    var genres = (movie.genres || []).join(', ');
    var text = (movie.title + ' ' + actors).toLowerCase();

    if (shown < 100 && text.includes(search)) {
      html += '<tr>';
      html += '<td>' + movie.title + (movie._conflicts ? ' <b>(conflict)</b>' : '') + '</td>';
      html += '<td>' + actors + '</td>';
      html += '<td>' + genres + '</td>';
      html += '<td><button onclick="editMovie(\'' + movie._id + '\')">Edit</button> ';
      html += '<button onclick="deleteMovie(\'' + movie._id + '\')">Delete</button></td>';
      html += '</tr>';
      shown++;
    }
  }

  document.getElementById('rows').innerHTML = html;
  document.getElementById('count').textContent = total + ' movies in local database';
  showConflicts(conflicts);
}

async function showConflicts(movies) {
  if (movies.length == 0) {
    document.getElementById('conflicts').innerHTML = 'none';
    return;
  }

  var html = '';
  for (var i = 0; i < movies.length; i++) {
    var versions = [movies[i]];
    for (var j = 0; j < movies[i]._conflicts.length; j++) {
      var other = await localDB.get(movies[i]._id, { rev: movies[i]._conflicts[j] });
      versions.push(other);
    }

    html += '<p><b>' + movies[i]._id + '</b></p>';
    for (var k = 0; k < versions.length; k++) {
      var v = versions[k];
      html += '<p>' + (k == 0 ? 'Winner' : 'Conflict') + ' (rev ' + v._rev + '): ';
      html += v.title + ' | ' + (v.actors || []).join(', ') + ' | ' + (v.genres || []).join(', ');
      html += ' <button onclick="keepVersion(\'' + v._id + '\', \'' + v._rev + '\')">Keep this version</button></p>';
    }
  }
  document.getElementById('conflicts').innerHTML = html;
}

async function keepVersion(id, rev) {
  var winner = await localDB.get(id, { conflicts: true });

  if (rev != winner._rev) {
    var chosen = await localDB.get(id, { rev: rev });
    chosen._rev = winner._rev;
    await localDB.put(chosen);
  }

  for (var i = 0; i < winner._conflicts.length; i++) {
    await localDB.remove(id, winner._conflicts[i]);
  }

  addLog('conflict on ' + id + ' fixed');
  showMovies();
}

showMovies();
startSync();

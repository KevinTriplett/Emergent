function getCookie(name) {
  var value = `; ${document.cookie}`;
  var parts = value.split(`; ${name}=`);
  if (parts.length === 2) return parts.pop().split(';').shift();
}

function setCookie(name, value) {
  // console.log(`setting cookie ${name}=${value}`);
  var date = new Date();
  date.setTime(date.getTime() + (7 * 24 * 60 * 60 * 1000)); // one week
  document.cookie = [
    `${ name }=${ value }`,
    `expires=${ date.toUTCString() }`,
    "path=/"
  ].join("; ");
}

// Returns a function, that, as long as it continues to be invoked, will not
// be triggered. The function will be called after it stops being called for
// `wait` milliseconds. If `immediate = true` is passed, trigger the function
// on the leading edge, instead of the trailing.
function debounce(func, wait, immediate) {
  var timeout;
  return function() {
      var context = this, args = arguments;
      var later = function() {
          timeout = null;
          if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
  };
};

var getUserGreeter = function(userRow) {
  var userGreeter = userRow.find("td.user-greeter a").first().text();
  return userGreeter == "make me greeter!" ? null : userGreeter;
}

var patch = function(userId, data) {
  var url = $("table.users").data("url");
  var token = $("table.users").data("token");
  $.ajax({
    url: url + "/" + userId + "/update_user",
    type: "POST",
    data: JSON.stringify({"user": data}),
    processData: false,
    dataType: 'JSON',
    contentType: 'application/json',
    headers: {
      'X-CSRF-Token': token
    },
    success: function() {
      window.location.reload();
    }
  });
}

var updateNotes = function(e) {
  var userNotes = $(e.currentTarget).val().trim();
  var userRow = $(e.currentTarget).closest("tr").prev().prev();
  var userId = userRow.data("id");
  var userGreeter = getUserGreeter(userRow);
  var userStatus = userRow.find("td.user-status a").first().text();
  var data = {
    "notes": userNotes,
    "greeter": userGreeter,
    "status": userStatus
  }
  patch(userId, data);
};

var loaded = false;
var prevGreeter = "";
document.addEventListener("turbo:load", function() {
  if(loaded) return;
  loaded = true;
  $("table.users td.more.user-questions").on("click", function() {
    $(this).closest("tr").next().toggle();
  });
  $("table.users td.more.user-notes").on("click", function() {
    $(this).closest("tr").next().next().toggle();
  });
  $("table.users td.user-notes-more textarea").on("keyup", debounce(updateNotes, 1000));
  $("table.users td.user-greeter a").on("click", function(e) {
    e.preventDefault();
    userGreeter = prompt("Enter your name", prevGreeter);
    if (userGreeter) {
      var userRow = $(this).closest("tr");
      prevGreeter = userGreeter;
      var userNotes = userRow.find("td.user-notes-more textarea").first().text();
      var userStatus = userRow.find("td.user-status a").first().text();
      var userId = userRow.data("id");
      var data = {
        notes: userNotes,
        greeter: userGreeter,
        status: userStatus
      };
      patch(userId, data);
    }
  });
  $("table.users td.user-status a").on("click", function(e) {
    e.preventDefault();
    userStatus = prompt("Enter new status");
    if (userStatus) {
      var userRow = $(this).closest("tr");
      var userNotes = userRow.find("td.user-notes-more textarea").first().text();
      var userGreeter = getUserGreeter(userRow);
      var userId = userRow.data("id");
      var data = {
        notes: userNotes,
        greeter: userGreeter,
        status: userStatus
      };
      patch(userId, data);
    }
  });
});


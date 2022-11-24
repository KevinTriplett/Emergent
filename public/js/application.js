////////////////////////////////////////////////////
// COOKIES
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

////////////////////////////////////////////////////
// DEBOUNCE
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

////////////////////////////////////////////////////
// UTILS
var getUserGreeter = function(userRow) {
  var userGreeter = userRow.find("td.user-greeter a").first().text();
  return userGreeter == "make me greeter!" ? null : userGreeter;
}

////////////////////////////////////////////////////
// PATCH
var patch = function(userId, data, success, error) {
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
    success: success,
    error: error
  });
}

////////////////////////////////////////////////////
// NOTES
var updateNotes = function(e) {
  var userNotesTextarea = $(e.currentTarget);
  var userNotes = userNotesTextarea.val().trim();
  var userRow = $(e.currentTarget).closest("tr").prev().prev();
  var userId = userRow.data("id");
  var userGreeter = getUserGreeter(userRow);
  var userStatus = userRow.find("td.user-status a").first().text();
  var data = {
    "notes": userNotes,
    "greeter": userGreeter,
    "status": userStatus
  }
  patch(userId, data, function() {
    userNotesTextarea
      .parent()
      .find("span.save-status")
      .addClass("success")
      .removeClass("failure")
      .text("saved");
  }, function() {
    userNotesTextarea
      .parent()
      .find("span.save-status")
      .addClass("failure")
      .removeClass("success")
      .text("failed");
  });
};

////////////////////////////////////////////////////
// EVENT LISTENERS
var loaded = false;
var prevGreeter = "";
document.addEventListener("turbo:load", function() {
  if (loaded) return; // set listeners only once
  loaded = true;

  ////////////////////////////////////////////////////
  // MORE EVENT LISTENERS
  $("table.users td.more.user-questions").on("click", function() {
    $(this).closest("tr").next().toggle();
  });
  $("table.users td.more.user-notes").on("click", function() {
    $(this).closest("tr").next().next().toggle();
  });

  ////////////////////////////////////////////////////
  // NOTES EVENT LISTENER
  $("table.users td.user-notes-more textarea").on("keyup", debounce(updateNotes, 1000));

  ////////////////////////////////////////////////////
  // GREETER EVENT LISTENER
  $("table.users td.user-greeter a").on("click", function(e) {
    e.preventDefault();
    var userGreeter = prompt("Enter your name", prevGreeter);
    if (userGreeter) {
      prevGreeter = userGreeter;
      var userRow = $(this).closest("tr");
      var userId = userRow.data("id");
      var userNotes = userRow.find("td.user-notes-more textarea").first().text();
      var userStatus = userRow.find("td.user-status a").first().text();
      var data = {
        notes: userNotes,
        greeter: userGreeter,
        status: userStatus
      };
      patch(userId, data, function() {
        userRow.find("td.user-greeter a").first().text(userGreeter);
      }, function() {
        alert("Could not change greeter - ask Kevin");
      });
    }
  });

  ////////////////////////////////////////////////////
  // STATUS EVENT LISTENER
  $("table.users td.user-status a").on("click", function(e) {
    e.preventDefault();
    var userStatus = prompt("Enter new status");
    if (userStatus) {
      var userRow = $(this).closest("tr");
      var userId = userRow.data("id");
      var userNotes = userRow.find("td.user-notes-more textarea").first().text();
      var userGreeter = getUserGreeter(userRow);
      var data = {
        notes: userNotes,
        greeter: userGreeter,
        status: userStatus
      };
      patch(userId, data, function() {
        userRow.find("td.user-status a").first().text(userStatus);
      }, function() {
        alert("Could not change status - ask Kevin");
      });
    }
  });
});


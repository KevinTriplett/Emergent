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
// EMAIL TEMPLATES
var emailTemplates = [
function(data) {
  return `Hi ${data.name},

Welcome to Emergent Commons. I'm one of the Greeters here.

I would like to schedule a time when we can talk in person, over Zoom, about being a member of Emergent Commons.

I'm pretty flexible with days and times. Can you let me know a few options that would work for you?

Again, welcome!
${data.greeter}`;
},
////////////////////////////////////////////////////
function(data) {
  return `Hi ${data.name},

Welcome to the Emergent Commons.
 
I'm one of the Greeter volunteers for Emergent Commons. I'd like to meet with you on Zoom to help you feel comfortable entering our community.
 
Let me know your time zone and your availability to have a conversation and we would choose time for our meeting. I plan to introduce myself and our community to you, show you around and answer any questions you may have.
 
Please feel free to explore our community site before we meet on zoom. I have already opened up our gate for you to look around and explore as much as you have time for. You could also go over items on the Welcome Checklist that should be visible on the right hand-side of your screen after you join.
 
Here are a few tips: 
- Crews are where most activities happen so check through the list and see if any pique your interest and then click the join button to keep up with what is happening inside.
 
- To stay more connected you might want to turn on notifications under your settings accessed through your picture icon/avatar. Make sure to set your location on your profile, that will allow you to see any events in your time zone.
 
- Don't hesitate to RSVP and join any events you are interested in, just mention that you are new and dive right in. 
 
I'm looking forward to hearing from you soon.
${data.greeter}`;
},
////////////////////////////////////////////////////
function(data) {
  return `Hi ${data.name},

Welcome to the Emergent Commons.

I'm one of the Greeters for Emergent Commons. I'd like to meet with you on Zoom to help you feel comfortable entering our community.

Please let me know your time zone and your availability to have a conversation so we would choose a day and time to meet.

And please feel free to explore our community site before we meet. I opened the gate for you to look around and explore as much as you have time and like.

You could also go over items on the Welcome Checklist that should be visible on the right-hand side of your screen after you join.

Here are a few tips: 

- Crews are where most activities happen so check through the list and see if any pique your interest and then click the join button to keep up with what is happening inside.

- To stay more connected you might want to turn on notifications under your settings accessed through your picture icon/avatar. Make sure to set your location on your profile, that will allow you to see any events in your time zone.

- Don't hesitate to RSVP and join any events you are interested in, just mention that you are new and dive right in. 

I look forward to hearing from you soon,
${data.greeter}`;
},
////////////////////////////////////////////////////
function(data) {
  return `Hi ${data.name},

Thanks for joining us at Emergent Commons. I'm one of the Greeters, to help you start exploring and engaging within the community. There's no central figure, we're a diverse bunch of people exploring ways to communicate with each other so we can understand the world and communicate with the people in it.

|||||||||||||||||| REVISE THIS PART ||||||||||||||||||
Comment on who they mentioned as someone they know here and about their other answers, so they know that we do pay attention to their answers and do want to know about them and what they desire from their experience at Emergent Commons
|||||||||||||||||| REVISE THIS PART ||||||||||||||||||

I'd love to chat in person, over Zoom, about the platform to make sure you get off to a fantastic start. If you'd rather explore on your own, just let me know and I'll send you some key points.

I'm pretty flexible with days and times. Can you let me know a few options that would work for you?

Again, welcome!

All the best,
${data.greeter}`;
}]

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
var convertTimeFromUTC = function(utc) {
  if (!utc) return null;
  var dt = (new Date(utc)).toLocaleString("en-GB").substring(0,17);
  // convert to iso 8601 format
  var t = dt.split(", ");
  var d = t.shift();
  d = d.split("/");
  return `${d[2]}-${d[1]}-${d[0]} ${t[0]}`;
}

var convertTimeToUTC = function(datetime) {
  datetime = new Date(datetime)
  if (datetime == "Invalid Date") return null;
  return datetime.toISOString();
}

var getUserGreeter = function(userDOM) {
  var userGreeter = userDOM.find("td.user-greeter a").text();
  return userGreeter == "I will greet" ? null : userGreeter;
}

var getUserShadow = function(userDOM) {
  var userShadow = userDOM.find("td.user-shadow a").text();
  return userShadow == "I will shadow" ? null : userShadow;
}

var getUserNotes = function(userDOM) {
  return userDOM.find("td.user-notes textarea").val();
}

var getPatchData = function(userDOM) {
  var userNotes = getUserNotes(userDOM);
  var userGreeter = getUserGreeter(userDOM);
  var userShadow = getUserShadow(userDOM);
  var userMeeting = userDOM.find("td.user-meeting-datetime input.datetime-picker").val();
  var userStatus = userDOM.find("td.user-status select").val();
  userMeeting = convertTimeToUTC(userMeeting);
  return {
    notes: userNotes,
    greeter: userGreeter,
    welcome_timestamp: userMeeting,
    shadow_greeter: userShadow,
    status: userStatus
  };
}

////////////////////////////////////////////////////
// PATCH
var patch = function(userId, data, success, error) {
  var url = $("table.users,table.user").data("url");
  var token = $("table.users,table.user").data("token");
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
// GLOBAL VARIABLES
var loaded = false;
var prevGreeter = getCookie("greeter-name");
var prevEmailTemplateIndex = getCookie("preferred-email-template-index");
var format = {
  timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
  hour12: false,
  year:"numeric",
  month: "2-digit",
  day: "2-digit",
  hour: "2-digit",
  minute: "2-digit"
};

////////////////////////////////////////////////////
// PAGE INITIALIZATION
$(document).ready(function() {
  if (loaded) return; // set listeners only once
  loaded = true;

  ////////////////////////////////////////////////////
  // CONNECT DATATABLE
  // ref https://datatables.net/reference/index
  $("table.users").DataTable({
    order: [[6,"desc"]],
    paging: false,
    fixedHeader: true,
    fixedColumn: true
  });

  ////////////////////////////////////////////////////
  // MAKE TABLE CELLS CLICKABLE
  $("table.users td, table.user td").on("click", function(e) {
    if (this === e.target) {
      if ($(this).find("a").length > 0) $(this).find("a")[0].click();
    }
  });

  ////////////////////////////////////////////////////
  // CONVERT ALL UTC TIMES TO LOCAL
  $(".utc-time").each( function(i, el) {
    el = $(el);
    var datetime = convertTimeFromUTC(el.val());
    el.val(datetime);
  });

  $("span.tzinfo").text(`(Times are ${Intl.DateTimeFormat().resolvedOptions().timeZone})`);

  $("a.user-approve").on("click", function(e) {
    loaded = false;
  });

  ////////////////////////////////////////////////////
  // MEETING DATETIME PICKER LISTENER
  var setUserMeeting = function(e) {
    var userDOM = $(this).closest("[data-id");
    var userId = userDOM.data("id");
    var data = getPatchData(userDOM);
    patch(userId, data, null, function() {
      alert("Could not set meeting date and time - ask Kevin");
    });
  }

  $( ".datetime-picker" ).on("click", function(e) {
    var el = $(this);
    if (el.data("picker")) return; // return if datetime picker already instantiated
    var userDOM = el.closest("[data-id]");
    var userId = userDOM.data("id");
    var options = {
      showTime: true,
      timeFormat: "HH:MM"
    };
    var css = `[data-id="${userId}"] input.datetime-picker`;
    el.data("picker", new dtsel.DTS(css, options));
    el.blur(); // now simulate opening the picker
    el.focus();
  }).on("change", debounce(setUserMeeting, 1000))
  .on("keydown", function(e) {
    switch(e.key) {
    case "Esc":
    case "Escape":
    case "Enter":
    case "Return":
      $(this).blur();
    }
  });

  ////////////////////////////////////////////////////
  // NOTES EVENT LISTENER
  var setUserNotes = function(e) {
    var userNotesTextarea = $(this)
    var userDOM = userNotesTextarea.closest("[data-id]");
    var userId = userDOM.data("id");
    var data = getPatchData(userDOM);
    patch(userId, data, function() {
      userNotesTextarea
        .parent()
        .find("span.save-status")
        .addClass("success")
        .removeClass("failure")
        .text("saved")
        .show();
    }, function() {
      userNotesTextarea
        .parent()
        .find("span.save-status")
        .addClass("failure")
        .removeClass("success")
        .text("failed")
        .show();
    });
  };

  $("table.user td.user-notes textarea")
    .on("keyup", debounce(setUserNotes, 1000))
    .on("keydown", function(e) {
      $(this)
        .parent()
        .find("span.save-status")
        .removeClass("success")
        .removeClass("failure")
        .text("").
        hide();
    });

  ////////////////////////////////////////////////////
  // GREETER EVENT LISTENER
  var setUserGreeter = function(userDOM, userGreeter) {
    var userId = userDOM.data("id");
    var data = getPatchData(userDOM);
    data.greeter = userGreeter;
    patch(userId, data, function() {
      userGreeter = userGreeter ? userGreeter : "I will greet"
      userDOM.find("td.user-greeter a").text(userGreeter);
    }, function() {
      alert("Could not change greeter - ask Kevin");
    });
  }

  $("td.user-greeter a").on("click", function(e) {
    e.preventDefault();
    var userGreeter = prompt("Enter your name", prevGreeter);
    if (userGreeter === null) return;
    prevGreeter = userGreeter;
    if (userGreeter === "") userGreeter = null;

    setCookie("greeter-name", prevGreeter); // save for next time

    var userDOM = $(this).closest("[data-id");
    setUserGreeter(userDOM, userGreeter);
  });

  ////////////////////////////////////////////////////
  // SHADOW EVENT LISTENER
  var setUserShadow = function(userDOM, userShadow) {
    var userId = userDOM.data("id");
    var data = getPatchData(userDOM);
    data.shadow_greeter = userShadow;
    patch(userId, data, function() {
      userShadow = userShadow ? userShadow : "I will shadow"
      userDOM.find("td.user-shadow a").text(userShadow);
    }, function() {
      alert("Could not change shadow - ask Kevin");
    });
  }

  // use same prevGreeter, since it's the user
  $("td.user-shadow a").on("click", function(e) {
    e.preventDefault();
    var userShadow = prompt("Enter your name", prevGreeter);
    if (userShadow === null) return;
    prevGreeter = userShadow;
    if (userShadow === "") userShadow = null;

    setCookie("greeter-name", prevGreeter); // save for next time

    var userDOM = $(this).closest("[data-id]");
    setUserShadow(userDOM, userShadow);
  });

  ////////////////////////////////////////////////////
  // STATUS EVENT LISTENER
  var setUserStatus = function(userDOM, userStatus) {
    var userId = userDOM.data("id");
    var data = getPatchData(userDOM);
    data.status = userStatus || data.status;
    patch(userId, data, function() {
      userDOM.find("td.user-status select").val(data.status);
    }, function() {
      alert("Could not change status - ask Kevin");
    });
  }

  $(".user-status select").selectmenu({
    change: function(e) {
      var userDOM = $(this).closest("[data-id]");
      setUserStatus(userDOM, null);
    }
  });

  ////////////////////////////////////////////////////
  // EMAIL EVENT LISTENER
  $("td.user-email a").on("click", function(e) {
    e.preventDefault();
    var userDOM = $(this).closest("[data-id]");
    var userGreeter = userDOM.find("td.user-greeter a").text();
    if (userGreeter == "I will greet") {
      alert("First, click 'I will greet' and then send the email");
      return;
    }

    var maxIndex = emailTemplates.length;
    var templateIndex = prompt(`Enter an email template 1 through ${maxIndex}`, prevEmailTemplateIndex);
    if (!templateIndex) return;

    templateIndex = parseInt(templateIndex) - 1;
    if (templateIndex < 0 || templateIndex > maxIndex - 1) {
      alert(`Choose an email template 1 through ${maxIndex}`);
      return;
    }

    prevEmailTemplateIndex = templateIndex + 1;
    setCookie("preferred-email-template-index", prevEmailTemplateIndex); // save for next time

    var userName = userDOM.find("td.user-name").text().trim();
    var userEmail = userDOM.find("td.user-email a").text().trim();
    var data = {
      name: userName,
      greeter: userGreeter
    };
    var body = emailTemplates[templateIndex](data);
    body = encodeURIComponent(body);
    var subject = "Scheduling your welcome Zoom to Emergent Commons 👋🏼"
    // var subject = "Volunteer from Emergent Commons greeting you 👋🏼";
    window.location.href = `mailto:${userEmail}?subject=${subject}&body=${body}`;
  });
});

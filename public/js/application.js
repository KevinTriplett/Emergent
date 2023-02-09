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
},
////////////////////////////////////////////////////
function(data) {
  return `Hi ${data.name},

First a very hearty welcome to Emergent Commons!
  
|||||||||||||||||| REVISE THIS PART ||||||||||||||||||
Second, I see you know Justin Franks! Besides knowing him at EC, I actually met him in person when I was visiting my sister-in-law last year in the DC area. Also, I see you are the Founder of Sacred Ground. I'm excited to meet you and also to see our commonality. (for examples see Landing Page answers)
  
And lastly, we like to meet one on one with new members. We have found everyone we meet with really likes it, finds it helpful, helps them understand our culture, and makes them feel more comfortable and at home in the community.
  
|||||||||||||||||| REVISE THIS PART ||||||||||||||||||
So, I'd like to invite you to a zoom meeting with me. Let me know what works for you. I am in the EST time zone. Right now I have open: 
  
Saturday, Dec 3rd after 3 pm, 
Sunday after 2:00 pm, 
Monday between 11:00 am and 3:00 pm, 
Wednesday between 11:00 am and 1:30 p
  
Let me know if any of these times work for you. Or suggest some times that work for you and what your time zone is.
    
I look forward to hearing from you.
  
Cheers,
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
var months = "NA Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec".split(" ");
var convertDtselTimeFromUTC = function(utc, dtPicker) {
  if (!utc) return null;
  var dt = (new Date(utc)).toLocaleString("en-GB").substring(0,17);
  // convert to iso 8601 format
  var t = dt.split(", ");
  var d = t.shift();
  d = d.split("/");
  return `${d[2]}-${d[1]}-${d[0]} ${t[0]}`;
}

var convertTimeFromUTC = function(utc, dtPicker) {
  if (!utc) return null;
  var dt = (new Date(utc)).toLocaleString("en-US");
  // convert to iso 8601 format
  var t = dt.split(", ")[1];
  var d = dt.split(",")[0].split("/");
  var ampm = t.split(" ")[1];
  t = t.split(":");
  return `${d[2]}-${months[d[0]]}-${d[1]} @ ${t[0]}:${t[1]} ${ampm}`;
}

var convertTimeToUTC = function(datetime) {
  datetime = new Date(datetime)
  if (datetime == "Invalid Date") return null;
  return datetime.toISOString();
}

var getUserMeeting = function(userDom) {
  var userMeetingDom = userDom.find("td.user-meeting-datetime input.datetime-picker");
  return convertTimeToUTC(userMeetingDom.val())
}

var getUserNotes = function(userDom) {
  return userDom.find("td.user-notes textarea").val();
}

var noGreeter = function(userDom) {
  var userGreeterId = userDom.find("td.user-greeter").data("greeter-id");
  if (!userGreeterId) {
    if (!confirm("You will greet this new member?")) return true;
    setUserGreeter(userDom, greeterId);
  } else if (userGreeterId != greeterId) {
    if (!confirm("You will greet this new member instead?")) return true;
    setUserGreeter(userDom, greeterId);
  }
  return false;
}

var setUserGreeter = function(userDom, newGreeterId) {
  var data = { greeter_id: newGreeterId };
  patch(userDom, data, function() {
    var text = newGreeterId ? greeterName : "I will greet";
    userDom.find("td.user-greeter").data("greeter-id", newGreeterId);
    userDom.find("td.user-greeter a").text(text);
  }, function() {
    alert("Could not change greeter - ask Kevin");
  });
}

var resetUserStatus = function(userDom) {
  var status = userDom.find("td.user-status").data("status");
  userDom.find("td.user-status select").val(status);
  userDom.find("td.user-status .ui-selectmenu-text").text(status);
}

var setStatus = function(userDom) {
  var status = userDom.find("td.user-status .ui-selectmenu-text").text();
  if ("Scheduling Zoom" == status) {
    if (!confirm("Set status to Zoom Scheduled?")) return true;
    setUserStatus(userDom, "Zoom Scheduled");
  } else if ("Zoom Scheduled" != status) {
    alert("Status must be Zoom Scheduled or Scheduling Zoom to set the Meeting date and time");
    return true;
  }
  return false;
}

var setUserStatus = function(userDom, userStatus) {
  var data = { status: userStatus || userDom.find("td.user-status select").val() };
  patch(userDom, data, function(result) {
    var newSel = document.createElement("select");
    for (const option of result.status_options) {
      var newOpt = document.createElement("option");
      newOpt.text = option;
      newOpt.value = option;
      newSel.add(newOpt, null);
    };
    userDom
      .find("td.user-status")
      .empty()
      .append(newSel);
    initStatusSelectMenu("td.user-status select");
    userDom.find("td.user-status").data("status", result.model.status);
    userDom.find("td.user-status select").val(result.model.status);
    userDom.find("td.user-status .ui-selectmenu-text").text(result.model.status);
    userDom.find("td.user-meeting-datetime input.datetime-picker").val(result.model.whenTimestamp)
  }, function() {
    alert("Could not change status - ask Kevin");
  });
}

var dateInPast = function(userDom, ts) {
  if (pastOkay || !ts) return false;
  if (Date.parse(ts) > (new Date).getTime()) return false;
  if (!confirm("Are you sure you want to set the Zoom meeting in the past?")) {
    var timestamp = userDom.find("td.user-meeting-datetime").data("timestamp");
    timestamp ||= "";
    userDom.find("td.user-meeting-datetime input").val(timestamp);
    return true;
  }
  pastOkay = true;
  return false;
}

var setUserMeeting = function(e) {
  var userDom = $(this).closest("[data-id]");
  var data = { when_timestamp: getUserMeeting(userDom) };
  if (dateInPast(userDom, data.when_timestamp)) return;
  patch(userDom, data, null, function() {
    alert("Could not set meeting date and time - ask Kevin");
  });
}

var initStatusSelectMenu = function() {
  $(".user-status select").selectmenu({
    change: function(e) {
      var userDom = $(this).closest("[data-id]");
      if (noGreeter(userDom)) {
        resetUserStatus(userDom);
        return;
      }
      setUserStatus(userDom, null);
    }
  });
}

////////////////////////////////////////////////////
// PATCH
var patch = function(userDom, data, success, error) {
  var url = userDom.dataset ? userDom.dataset.url : userDom.data("url");
  var token = userDom.dataset ? userDom.dataset.token : userDom.data("token");
  $.ajax({
    url: url,
    type: "POST",
    data: JSON.stringify({"model": data}),
    processData: false,
    dataType: "JSON",
    contentType: "application/json",
    headers: {
      "X-CSRF-Token": token
    },
    success: function(result) {
      if (success) success(result);
      updateChangeLog(result.model);
    },
    error: error
  });
}

var updateChangeLog = function(model) {
  if (!model || !model.change_log) return;
  $("td.change-log").html(model.change_log.replace(/\n/g, "<br>"));
}

////////////////////////////////////////////////////
// GLOBAL VARIABLES
var loaded = false;
var greeterName = getCookie("user_name");
if (greeterName) greeterName = greeterName.replace("+", " ");
var greeterId = getCookie("user_id");
var prevEmailTemplateIndex = getCookie("preferred-email-template-index");
var pastOkay = false;
var format = {
  timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
  hour12: false,
  year:"numeric",
  month: "2-digit",
  day: "2-digit",
  hour: "2-digit",
  minute: "2-digit"
};
var progressMessages = [
  "Establishing secure channel ...",
  "Contacting HQ ...",
  "Exchanging credentials ...",
  "Looking up member request ...",
  "Sending request to approve ...",
  "Getting response ...",
  "Disconnecting from HQ ...",
  "Cleaning up channel ...",
  "Updating database ...",
  "Waiting, not much longer now ..."
]

////////////////////////////////////////////////////
// PAGE INITIALIZATION
$(document).ready(function() {
  if (loaded) return; // set listeners only once
  loaded = true;
  $("#spinner").hide();
  $(document).uitooltip();

  ////////////////////////////////////////////////////
  // USER SEARCH
  $("#user-search").on("blur", function() {
    // hideUserList(); // cannot do this or cannot select user from autocomplete box
  }).on("keyup", function() {
    var self = $(this);
    var value = self.val();
    if (value.length < 2) return;
    var token = self.data("token");
    var url = self.data("url");
    var data = {search_terms: value};
    $.ajax({
      url: url,
      type: "GET",
      data: data,
      dataType: 'JSON',
      contentType: 'application/json',
      success: function(result) {
        createUserList(result.users);
        showUserList();
      }
    });
  });

  var initUserList = function() {
    $(".autocom-box").on("click", function(e) {
      var li = $(e.target).closest("li");
      var userName = li.find("span.user-name").text();
      var userId = li.find("span.user-id").text();
      $("#user-search").val(userName);
      $("#survey_invite_user_id").val(userId);
      hideUserList();
    });
  }
  initUserList();

  var createUserList = function(users) {
    var list = document.createElement("ul");
    for (user of users) {
      var li = document.createElement("li");
      var spanName = document.createElement("span");
      var spanId = document.createElement("span");
      spanName.className = "user-name";
      spanId.className = "user-id";
      spanName.innerText = user[1];
      spanId.innerText = user[0];
      li.appendChild(spanName);
      li.appendChild(spanId);
      list.appendChild(li);
    }
    $(".autocom-box")
      .empty()
      .append(list)
  };

  var showUserList = function() {
    $(".autocom-box").show();
  }
  var hideUserList = function() {
    $(".autocom-box").hide()
  }
  hideUserList();

  ////////////////////////////////////////////////////
  // SORTABLE SURVEY QUESTIONS
  $("#sortable")
    .sortable({
      stop: function(e, ui) {
        ui
          .item
          .closest("tbody")
          .find("tr")
          .each(function(i, tr) {
            patch(tr, {position: i}, function(result) {
              tr.dataset.position = result.model.position;
            }, function() {
              $("#sortable").sortable("cancel");
              alert("something went wrong -- ask Kevin");
            });
          });
      }
    });

  ////////////////////////////////////////////////////
  // RESIZE NOTES TEXTAREA
  // ref https://stackoverflow.com/a/48460773/1204064
  var scrollHeight = $(".user-notes textarea").prop("scrollHeight");
  $(".user-notes textarea")
    .css("height", "")
    .css("height", scrollHeight * 1.04 + "px")
    .on("input", function(e) {
      this.style.height = "";
      this.style.height = this.scrollHeight * 1.04 + "px";
    });

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
  // MAKE TABLE ROWS CLICKABLE
  $("table.users tbody tr").on("click", function(e) {
    if (e.target.nodeName == "A") return;
    document.location = this.closest("tr").dataset["url"];
  });

  ////////////////////////////////////////////////////
  // CONVERT ALL UTC TIMES TO LOCAL
  $(".user-meeting-datetime.utc-time").each( function(i, el) {
    el = $(el);
    if (!el.text()) return;
    var datetime = convertTimeFromUTC(el.text());
    el.text(datetime);
  });

  $(".datetime-picker.utc-time").each( function(i, el) {
    el = $(el);
    if (!el.val()) return;
    var datetime = convertDtselTimeFromUTC(el.val());
    el.val(datetime);
  });

  $("span.tzinfo").text(`(Times are ${Intl.DateTimeFormat().resolvedOptions().timeZone})`);

  ////////////////////////////////////////////////////
  // APPROVE AND REJECT BUTTONS
  $("input#my-greetings").on("change", function() {
    if (!this.checked) {
      $("table.users tbody tr:hidden").show();
    } else {
      $("table.users tbody tr").each(function() {
        var el = $(this);
        if (el.find("td.user-greeter").text() != greeterName) el.hide();
      });
    }
  });

  ////////////////////////////////////////////////////
  // APPROVE AND REJECT BUTTONS
  $("a.user-reject").on("click", function(e) {
    e.preventDefault();
    alert("Contact a Host to reject this request");
  });

  $("a.user-approve").on("click", function(e) {
    e.preventDefault();
    self = $(this);
    var userDom = self.closest("[data-id]");
    if (noGreeter(userDom)) return;
    var url = self.attr("href");
    var token = $("table.users,table.user").data("token");
    $("#spinner").show();
    $(".progress-message").show();
    $(".user-approve,.user-reject").hide();
    
    // set up the spinner
    var count = 0;
    var msgTimer = setInterval(function() {
      var msg = progressMessages[count++];
      $(".progress-message").text(msg);
    }, 5000);

    $.ajax({
      url: url,
      type: "POST",
      data: null,
      processData: false,
      dataType: 'JSON',
      contentType: 'application/json',
      headers: {
        'X-CSRF-Token': token
      },
      success: function(result) {
        window.location.assign(result.url);
      },
      error: function(result) {
        clearInterval(msgTimer);
        $("#spinner").hide();
        $(".progress-message")
          .text("Something went wrong -- ask Kevin")
          .addClass("failure");
      }

    });
  });

  ////////////////////////////////////////////////////
  // MEETING DATETIME PICKER LISTENER
  $( ".datetime-picker" )
    .on("click", function(e) {
      var el = $(this);
      var userDom = el.closest("[data-id]");
      if (noGreeter(userDom) || setStatus(userDom)) {
        el.blur();
        return;
      }
      if (el.data("picker")) return; // return if datetime picker already instantiated
      var options = {
        showTime: true,
        timeFormat: "HH:MM"
      };
      var css = "input.datetime-picker";
      el.data("picker", new dtsel.DTS(css, options))
        .blur() // now simulate opening the picker
        .focus();
    })
    .on("change", debounce(setUserMeeting, 500))
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
    var userDom = userNotesTextarea.closest("[data-id]");
    var data = { notes: getUserNotes(userDom) };
    patch(userDom, data, function() {
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
  $("td.user-greeter a").on("click", function(e) {
    e.preventDefault();
    var self = $(this);
    var result = true;
    var currentGreeterId = self.closest("td").data("greeter-id");
    var newGreeterId = greeterId;
    if (currentGreeterId == greeterId) {
      result = confirm("Remove yourself as greeter?");
      newGreeterId = result ? null : id;
    } else if (currentGreeterId) {
      if (!confirm("You will greet instead?")) return;
    }
    var userDom = $(this).closest("[data-id]");
    setUserGreeter(userDom, newGreeterId);
  });

  ////////////////////////////////////////////////////
  // SHADOW EVENT LISTENER
  $("td.user-shadow a").on("click", function(e) {
    e.preventDefault();
    var self = $(this);
    var result = true;
    var currentGreeterId = self.closest("td").data("greeter-id");
    var newGreeterId = greeterId;
    if (currentGreeterId == greeterId) {
      result = confirm("Remove yourself as shadow greeter?");
      newGreeterId = result ? null : id;
    } else if (currentGreeterId) {
      result = confirm("You will be the shadow greeter instead?\n(we prefer only one shadow greeter)");
    }
    if (!result) return;
    var userDom = $(this).closest("[data-id]");
    var data = { shadow_greeter_id: newGreeterId };
    patch(userDom, data, function() {
      var text = newGreeterId ? greeterName : "I will shadow";
      self.closest("td").data("greeter-id", newGreeterId);
      userDom.find("td.user-shadow a").text(text);
    }, function() {
      alert("Could not change shadow - ask Kevin");
    });
  });

  ////////////////////////////////////////////////////
  // STATUS EVENT LISTENER
  initStatusSelectMenu("td.user-status select");

  ////////////////////////////////////////////////////
  // EMAIL EVENT LISTENER
  $("td.user-email a").on("click", function(e) {
    e.preventDefault();
    var userDom = $(this).closest("[data-id]");
    if (noGreeter(userDom)) return;
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

    var newMemberName = userDom.find("td.user-name").text().trim();
    var newMemberEmail = userDom.find("td.user-email a").text().trim();
    var data = {
      name: newMemberName,
      greeter: greeterName
    };
    var body = emailTemplates[templateIndex](data);
    body = encodeURIComponent(body);
    var subject = "Scheduling your welcome Zoom to Emergent Commons 👋🏼"
    // var subject = "Volunteer from Emergent Commons greeting you 👋🏼";
    window.location.href = `mailto:${newMemberEmail}?subject=${subject}&body=${body}`;
  });
});

////////////////////////////////////////////////////
// GLOBAL VARIABLES
var loaded = false;
var greeterName = getCookie("user_name");
if (greeterName) greeterName = greeterName.replace("+", " ");
var greeterId = getCookie("user_id");
var pastOkay = false;
var optVisible = false;
var errorMsgCount = prevErrorMsgCount = 0;
var metaKeyDown = false;
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
  "Contacting Mighty Networks ...",
  "Exchanging credentials ...",
  "Asking about the family, getting a check-in ...",
  "Looking up this member request ...",
  "Politing asking to approve the request ...",
  "Getting response ...",
  "Yep, no problem, got the approval ...",
  "Getting a check-out, saying goodbye ...",
  "Disconnecting from Mighty Networks ...",
  "Cleaning up the channel ...",
  "Updating our database ...",
  "Waiting, not much longer now ...",
  "I promise, not much longer ...",
  "Thanks for being patient :) ...",
  "Whoops, looks like something went wrong ...",
  "Please refresh the page"
]

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
// EMAIL GREETING TEMPLATES
var emailGreetingTemplates = [
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
// EMAIL CLARIFICATION TEMPLATES
var emailClarificationTemplates = [
  function(data) {
    return `Hi ${data.name},
  
I am a Greeter at Emergent Commons and saw your recent request to join our community. I am writing because your responses to our Landing Page questions seem too brief and/or insufficient. If you are still interested in joining, would you please elaborate on your responses to these questions and re-submit your request?

1.   What drew you to this community? What do you hope to experience here?
2.   We do not have an individual or a team creating, curating or broadcasting content. It's our members that bring the content, create events, start groups and spark discussion. What lights you up and how do you think you might share that here?

Here is the link to request joining:
https://emergent-commons.mn.co/
  
If you have any questions about this, please reply to this email.
  
Thank you,
${data.greeter}`;
},
  ////////////////////////////////////////////////////
  function(data) {
    return `Hi ${data.name},

I am one of the greeters volunteers for the Emergent Commons community that you recently requested to join. Because a main focus in this community is relational in nature we put a lot of thought into our initial questionnaire to the prospective members and we appreciate thoughtful answers. Our onboarding process includes an offering to meet on zoom to every new member after the questionnaire gets reviewed and answers get accepted. Before I could proceed with our onboarding process I would like to get some clarifications from you sent to me as a response to this email.

You answered: "Jupitor R." to our two questions:

1. What drew you to this community?
2. What do you hope to experience here?

I am not familiar with that phrase in the context of our questions. Could you please try elaborating on each of these two questions for
me?

The next two questions are also pretty important for us especially because we do not have an individual or a team creating, curating or broadcasting content. It's our members that bring the content, create events, start groups and spark discussion. Based on your answer, I see that you are very interested in the meta-crisis and you are in the right place, indeed. Could you please try elaborating on the next two questions for me?

3. What lights you up?
4. How do you think you might share that here?

I am looking forward to hearing from you soon,
${data.greeter}`;
}]

////////////////////////////////////////////////////
// DEBOUNCE
// Returns a function, that, as long as it continues to be invoked, will not
// be triggered. The function will be called after it stops being called for
// `wait` milliseconds. If `immediate = true` is passed, trigger the function
// on the leading edge, instead of the trailing.
var debounce = function(func, wait, immediate) {
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
  var t = dt.split(/,\s/)[1];
  var d = dt.split(",")[0].split("/");
  var ampm = t.split(/\s/)[1];
  t = t.split(":");
  return `${d[2]}-${months[d[0]]}-${d[1]} @ ${t[0]}:${t[1]} ${ampm}`;
}

var convertTimeToUTC = function(datetime) {
  datetime = new Date(datetime)
  if (datetime == "Invalid Date") return null;
  return datetime.toISOString();
}

var getUserMeeting = function(userDom) {
  var userMeetingDom = userDom.find("input.datetime-picker");
  return convertTimeToUTC(userMeetingDom.val())
}

var getUserNotes = function(userDom) {
  return userDom.find(".user-notes textarea").val();
}

var noGreeter = function(userDom) {
  var userGreeterId = userDom.closest("[data-greeter-id]").attr("data-greeter-id");
  if (!userGreeterId) {
    if (!confirm("You will greet this new member?")) return true;
    setUserGreeter(userDom, greeterId);
  }
  return false;
}

var setUserGreeter = function(userDom, newGreeterId) {
  var data = { greeter_id: newGreeterId };
  patch(userDom, data, function() {
    var text = newGreeterId ? greeterName : "I want to greet";
    userDom.attr("data-greeter-id", newGreeterId);
    userDom.find(".user-greeter a").text(text);
  }, function() {
    alert("Could not change greeter - ask Kevin");
  });
}

var setUserStatus = function(userDom, userStatus) {
  var data = { status: userStatus || userDom.find(".user-status select").val() };
  patch(userDom, data, function(result) {
    var newSel = document.createElement("select");
    for (const option of result.status_options) {
      var newOpt = document.createElement("option");
      newOpt.text = option;
      newOpt.value = option;
      newSel.add(newOpt, null);
    };
    userDom
      .find(".user-status")
      .empty()
      .append(newSel);
    initStatusSelectMenu();
    userDom.find(".user-status").attr("data-status", result.model.status);
    userDom.find(".user-status select").val(result.model.status).selectmenu("refresh");
    userDom.find(".user-meeting-datetime input.datetime-picker").val(result.model.whenTimestamp)
  }, function() {
    alert("Could not change status - ask Kevin");
  });
}

var dateInPast = function(userDom, ts) {
  if (pastOkay || !ts) return false;
  if (Date.parse(ts) > (new Date).getTime()) return false;
  if (!confirm("Are you sure you want to set the Zoom meeting in the past?")) {
    var timestamp = userDom.find(".user-meeting-datetime").attr("data-timestamp");
    timestamp ||= "";
    userDom.find(".user-meeting-datetime input").val(timestamp);
    return true;
  }
  pastOkay = true;
  return false;
}

var setUserMeeting = function(e) {
  var userDom = $(this).closest("[data-id]");
  var data = { when_timestamp: getUserMeeting(userDom) };
  if (dateInPast(userDom, data.when_timestamp)) return;
  patch(userDom, data, function() {
    $(".schedule-zoom").show();
  }, function() {
    alert("Could not set meeting date and time - ask Kevin");
  });
}

var initStatusSelectMenu = function() {
  $(".user-status select").selectmenu({
    change: function(e) {
      var userDom = $(this).closest("[data-id]");
      setUserStatus(userDom, null);
    }
  });
}

var initSurveySelectMenu = function() {
  $("#question-type select, #answer-type select").selectmenu({
    change: function(e) {
      var self = $(this);
      self
        .closest(".row")
        .find("input[type='hidden']")
        .val(self.val());
    }
  });
}

////////////////////////////////////////////////////
// PATCH
var patch = function(userDom, data, success, error) {
  var url = userDom.dataset ? userDom.dataset.url : userDom.attr("data-url");
  var token = userDom.dataset ? userDom.dataset.token : userDom.attr("data-token");
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
  $(".change-log").html(model.change_log.replace(/\n/g, "<br>"));
}

var showOpt = function(show) {
  if (!(show ^ optVisible)) return;
  optVisible = show;
  if (show)
    debounce(function() {
      $(".opt").show();
    }, 5000)();
  else {
    debounce(function() {
      $(".opt").hide();
    }, 1000)();
  }
}

////////////////////////////////////////////////////
// PAGE INITIALIZATION
$(document).ready(function() {
  if (loaded) return; // set listeners only once
  loaded = true;
  $("#spinner").hide();
  $(document)
    .uitooltip()
    .on("keydown", function(e) {
      showOpt(e.altKey);
      metaKeyDown = e.metaKey;
    }).on("keyup", function(e) {
      showOpt(e.altKey);
      metaKeyDown = e.metaKey
    });

  ////////////////////////////////////////////////////
  // DELETE LINKS
  var deleteThis = function(e, success, error) {
    e.preventDefault();
    if (!confirm(this.dataset["confirm"])) return;
    var token = $(this).closest("[data-token]").attr("data-token");
    var url = this.href || $(this).attr("data-url");
    $.ajax({
      url: url,
      type: "DELETE",
      headers: {
        'X-CSRF-Token': token
      },
      success: function(result) {
        if (success) success(result);
      },
      error: error
    })
  }

  $("a[data-method='delete']").on("click", function(e) {
    deleteThis.call(this, e,
      function(result) {
        window.location.assign(result.url);
      },
      function() {
        alert("Unable to delete -- ask Kevin");
      }
    );
  });

  ////////////////////////////////////////////////////
  // CONNECT DATATABLE
  // ref https://datatables.net/reference/index
  $("table.users").DataTable({
    order: [[5,"desc"]],
    paging: false,
    fixedHeader: true,
    fixedColumn: true
  });
  $(".controls").detach().appendTo(".dataTables_wrapper > div:first-child > div:first-child");
  $(".dataTables_wrapper input[type='search']").on("keyup", function() {
    var self = $(this);
    var value = self.val();
    if (value.length < 3) return;
    var url = self.closest("[data-url]").attr("data-url");
    var data = {q: value, source: "greeter"};
    $.ajax({
      url: url,
      type: "GET",
      data: data,
      dataType: 'JSON',
      contentType: 'application/json',
      success: function(result) {
        var tbody = $(document.querySelector("table.users tbody"));
        var tr, td;
        tbody.find("tr.search").remove();
        var ids = tbody.find("tr").map(function(i, row) {
          return parseInt(row.dataset.id);
        });
        for (user of result.users) {
          if (ids.index(user.id) != -1) continue;
          tr = document.createElement("tr");
          tr.dataset.url = user.url;
          tr.dataset.id = user.id;
          tr.className = `${user.classnames} search`;
          td = document.createElement("td");
          td.className = "user-name";
          td.innerText = user.name;
          tr.appendChild(td);
          td = document.createElement("td");
          td.className = "user-greeter";
          td.innerText = user.greeter;
          tr.appendChild(td);
          td = document.createElement("td");
          td.className = "user-status";
          td.innerText = user.status;
          tr.appendChild(td);
          td = document.createElement("td");
          td.className = "user-meeting";
          td.innerText = user.when;
          tr.appendChild(td);
          td = document.createElement("td");
          td.className = "user-shadow";
          td.innerText = user.shadow;
          tr.appendChild(td);
          td = document.createElement("td");
          td.className = "user-notes";
          td.innerText = user.notes;
          td.setAttribute("title", user.truncated);
          tr.appendChild(td);
          td = document.createElement("td");
          td.className = "user-request";
          td.innerText = user.request;
          tr.appendChild(td);
          tbody.append(tr);
        }
      }
    });
  });

  ////////////////////////////////////////////////////
  // USER SEARCH
  $("#search input[type='search']").on("blur", function() {
    // hideUserList(); // cannot do this or cannot select user from autocomplete box
  }).on("keyup", function() {
    var self = $(this);
    var value = self.val();
    if (value.length < 2) return;
    var url = self.attr("data-url");
    var data = {q: value};
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
      $("#search input[type='search']").val(userName);
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
  // SORTABLE ELEMENTS
  $(".sortable")
    .sortable({
      stop: function(e, ui) {
        prevErrorMsgCount = errorMsgCount;
        ui
          .item
          .closest(".sortable")
          .find("> .ui-state-default")
          .each(function(i, dom) {
            patch(dom, {position: i}, function(result) {
              dom.dataset.position = result.model.position;
            }, function() {
              $(".sortable").sortable("cancel");
              if (errorMsgCount == prevErrorMsgCount) alert("something went wrong -- ask Kevin");
              errorMsgCount++
            });
          }
        )},
      cancel: ".contenteditable"
    });

  ////////////////////////////////////////////////////
  // RESIZE NOTES TEXTAREA
  // ref https://stackoverflow.com/a/48460773/1204064
  $("textarea").each(function() {
    var self = $(this);
    var scrollHeight = self.prop("scrollHeight");
    self
      .css("height", "")
      .css("height", scrollHeight * 1.04 + "px")
      .on("input", function(e) {
        this.style.height = "";
        this.style.height = this.scrollHeight * 1.04 + "px";
      });
  });

  ////////////////////////////////////////////////////
  // MAKE TABLE ROWS CLICKABLE
  $("table.users tbody").on("click", function(e) {
    if (e.target.nodeName == "A") return;
    document.location = $(e.target).closest("tr").attr("data-url");
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
  // FILTER VIEW BY PENDING AND MY GREETINGS
  var showHideUsers = function(showAll) {
    if (showAll) $("table.users tbody tr:hidden").show();
    else $("table.users tbody tr").each(function() {
      var self = $(this);
      var hide = self.attr("data-greeter-id") != greeterId &&
        self.attr("data-status") != "Pending" &&
        self.attr("data-status") != "Clarification Needed"
      if (hide) self.hide();
    });
  }
  $("input#show-all-greetings").on("change", function() {
    showHideUsers(this.checked);
  });
  showHideUsers(false);

  ////////////////////////////////////////////////////
  // GREETER WIZARD
  $("a.reveal-answers").on("click", function(e) {
    e.preventDefault();
    $(".user-questions").toggle();
  })
  $("a.reveal-change-log").on("click", function(e) {
    e.preventDefault();
    $(".change-log").toggle();
  });

  ////////////////////////////////////////////////////
  // GREETER AND CLARIFICATION EMAIL TEMPLATE BUTTONS
  // USED BY THE FOLLOWING TWO CONDITIONAL STATEMENTS
  var createEmailTemplateButton = function(dom, func, subject, buttonText=null) {
    var button = $(document.createElement("a"));
    button.addClass("btn btn-secondary");
    button.attr("href", "#");
    button.data("func", func);
    button.on("click", function(e) {
      e.preventDefault();
      var self = $(this);
      var func = self.data("func");
      var data = {
        name: $(".user-name").first().text(),
        greeter: greeterName
      };
      self
        .closest(".user-email")
        .find(".email-body")
        .text(func(data))
        .trigger("input");
      self
        .closest(".user-email")
        .find(".email-subject")
        .val(subject);
    });
    buttonText ||= `Template ${dom.children().length + 1}`;
    button.text(buttonText);
    dom.append(button);
  }

  var templateButtons = $(".email-template-buttons.greeting");
  if (templateButtons.length > 0) {
    templateButtons.empty();
    for (templateFunc of emailGreetingTemplates) {
      createEmailTemplateButton(
        templateButtons, 
        templateFunc,
        "Scheduling your welcome Zoom to Emergent Commons"
      );
    }
    var lastEmailSubject = getCookie("subject");
    var lastEmailBody = getCookie("body");
    if (lastEmailSubject || lastEmailBody) {
      lastEmailBody = decodeURIComponent(lastEmailBody);
      var lastEmailFunc = function() { return lastEmailBody; };
      createEmailTemplateButton(
        templateButtons, 
        lastEmailFunc,
        lastEmailSubject,
        "Your Most Recent Email"
      );
    }
  }

  templateButtons = $(".email-template-buttons.clarification");
  if (templateButtons.length > 0) {
    templateButtons.empty();
    for (templateFunc of emailClarificationTemplates) {
      createEmailTemplateButton(
        templateButtons, 
        templateFunc,
        "Following up on your request to join Emergent Commons"
      );
    }
  }

  ////////////////////////////////////////////////////
  // EMAIL SEND

  $('.use-gmail')
    .each(function(){ this.checked = getCookie("use-gmail") == "true"; })
    .on("click", function() {
      setCookie("use-gmail", this.checked);
    });

  $(".email-send").on("click", function(e) {
    e.preventDefault();
    var self = $(this).closest(".user-email");
    var email = self.find(".email-address").text().trim();
    var subject = self.find(".email-subject").val().trim();
    var body = self.find(".email-body").val().trim();
    body = encodeURIComponent(body);
    var useGmail = self.find("input.use-gmail").is(":checked");
    var mailUrl = useGmail ?
      // ref https://stackoverflow.com/questions/6988355/open-gmail-on-mailto-action
      `https://mail.google.com/mail/?view=cm&fs=1&to=${email}&su=${subject}&body=${body}` :
      `mailto:${email}?subject=${subject}&body=${body}`
    window.open(mailUrl);
    if ($(this).hasClass("clarification")) return;
    setCookie("subject", subject);
    setCookie("body", body);
    // // use the app to send email:
    // var self = $(this);
    // var url = self.closest("[data-email-url]").attr("data-email-url");
    // var token = self.closest("[data-token]").attr("data-token");
    // var data = {
    //   subject: subject,
    //   body: body  
    // };
    // $.ajax({
    //   url: url,
    //   type: "POST",
    //   data: JSON.stringify(data),
    //   processData: false,
    //   dataType: 'JSON',
    //   contentType: 'application/json',
    //   headers: {
    //     'X-CSRF-Token': token
    //   },
    //   success: function(result) {
    //     window.location.href = result.url;
    //   },
    //   error: function(data, textStatus, jqXHR) {
    //     alert("Something went wrong -- ask Kevin");
    //   }
    // });
  });

  ////////////////////////////////////////////////////
  // APPROVE AND REJECT BUTTONS
  $("a.user-approve").on("click", function(e) {
    e.preventDefault();
    var self = $(this);
    var url = self.attr("href");
    var token = self.closest("[data-token]").attr("data-token");
    $("#spinner").show();
    $(".progress-message").show();
    $(".user-approve,.user-reject").hide();
    
    // set up the spinner
    var count = 0;
    var msgTimer = setInterval(function() {
      var msg = progressMessages[count++];
      $(".progress-message").text(msg);
    }, 2500);

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
      if (el.attr("data-picker")) return; // return if datetime picker already instantiated
      var options = {
        showTime: true,
        timeFormat: "HH:MM"
      };
      var css = "input.datetime-picker";
      el.attr("data-picker", new dtsel.DTS(css, options))
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
    $(".schedule-zoom").hide();

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

  $(".user-notes textarea")
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
  $(".user-greeter a").on("click", function(e) {
    e.preventDefault();
    var result = true;
    var userDom = $(this).closest("[data-url]");
    var currentGreeterId = userDom.attr("data-greeter-id");
    var newGreeterId = greeterId;
    if (currentGreeterId == greeterId) {
      result = confirm("Remove yourself as greeter?");
      newGreeterId = result ? null : id;
    }
    setUserGreeter(userDom, newGreeterId);
  });

  ////////////////////////////////////////////////////
  // SHADOW EVENT LISTENER
  $(".user-shadow a").on("click", function(e) {
    e.preventDefault();
    var result = true;
    var userDom = $(this).closest("[data-url]");
    var currentGreeterId = userDom.attr("data-shadow-id");
    var newGreeterId = greeterId;
    if (currentGreeterId == greeterId) {
      result = confirm("Remove yourself as shadow greeter?");
      newGreeterId = result ? null : id;
    } else if (currentGreeterId) {
      result = confirm("You will be the shadow greeter instead?\n(we prefer only one shadow greeter)");
    }
    if (!result) return;
    var data = { shadow_greeter_id: newGreeterId };
    patch(userDom, data, function() {
      var text = newGreeterId ? greeterName : "I want to shadow";
      userDom.attr("data-shadow-id", newGreeterId);
      userDom.find(".user-shadow a").text(text);
    }, function() {
      alert("Could not change shadow - ask Kevin");
    });
  });

  ////////////////////////////////////////////////////
  // STATUS EVENT LISTENER
  initStatusSelectMenu();
  initSurveySelectMenu();

  ////////////////////////////////////////////////////
  // SURVEY
  var saveAnswer = function(e) {
    var self = $(this);
    var data = self.val();
    surveyAnswerPatch(self, {answer: data});
  }
  var saveScale = function(e) {
    var self = $(this);
    var data = self.val();
    surveyAnswerPatch(self, {scale: data});
  }
  $("#survey-container .survey-answer-essay textarea").on("keyup", debounce(saveAnswer, 500));
  $("#survey-container .survey-answer-range input[type='range']").on("change", debounce(saveAnswer, 500));
  $("#survey-container .survey-answer-yes-no input[type='radio']").on("change", saveAnswer);
  $("#survey-container .survey-answer-multiple-choice input[type='radio']").on("change", saveAnswer);
  $("#survey-container .survey-answer-email input").on("keyup", debounce(saveAnswer, 500));
  $("#survey-container .survey-answer-scale input[type='range']").on("change", debounce(saveScale, 500));

  var processVote = function(e) {
    var self = $(this);
    var count = self.parent().find(".vote-count");
    var votes = parseInt(count.text());
    votes = votes + (self.hasClass("vote-up") ? 1 : -1);
    surveyAnswerPatch(self, {votes: votes}, function(result) {
      count.text(result.vote_count);
      self
        .closest("#survey-container, #notes-container")
        .find(`[data-group-id='${result.group_id}']`)
        .find(".votes-left")
        .text(result.votes_left);
      switch(result.vote_thirds) {
      case 0:
        self.closest(".main").find(".hearts i").hide();
        break;
      case 1:
        self.closest(".main").find(".hearts i").hide();
        self.closest(".main").find(".hearts i.one-third").show();
        break;
      case 2:
        self.closest(".main").find(".hearts i").hide();
        self.closest(".main").find(".hearts i.two-thirds").show();
        break;
      default:
        self.closest(".main").find(".hearts i").hide();
        self.closest(".main").find(".hearts i.three-thirds").show();
      }
    });
  }
  $("#survey-container .vote-up, #survey-container .vote-down").on("click", processVote);

  var surveyAnswerPatch = function(dom, data, success, error) {
    var urlDom = dom.closest("[data-url]");
    var token = urlDom.attr("data-token");
    var url = urlDom.attr("data-url");
    $.ajax({
      url: url,
      type: "POST",
      data: JSON.stringify({"survey_answer": data}),
      processData: false,
      dataType: "JSON",
      contentType: "application/json",
      headers: {
        "X-CSRF-Token": token
      },
      success: function(result) {
        if (success) success(result);
      },
      error: error
    });
  }

  ////////////////////////////////////////////////////
  // NOTES
  var userView = function() {
    return $("#notes-container.admin").length == 0
  }

  // ----------------------------------------------------------------------
  // NOTE FLASH (indicate success/failure for note CRUD actions)

  var flashSuccess = function(note) {
    note.find(".bi-check").show();
  }
  var flashError = function(note) {
    note.find(".bi-exclamation").show();
  }
  var flashHide = function(note) {
    note.find(".bi-check").hide();
    note.find(".bi-exclamation").hide();
  }

  // ----------------------------------------------------------------------
  // NOTE SETTERS-GETTERS

  var getNoteData = function(note) {
    return {
      noteCssId: getNoteId(note),
      text: getNoteText(note),
      groupName: getNoteGroupName(note),
      groupId: getNoteGroupId(note),
      color: getNoteColor(note),
      coords: getNoteCoords(note),
      patchUrl: getNotePatchUrl(note),
      deleteUrl: getNoteDeleteUrl(note),
      zIndex: getNoteZIndex(note),
      dataset: getNoteDataset(note),
      style: getNoteStyle(note),
      prevData: getNotePrevData(note)
    }
  }
  var updateNoteFromData = function(note, data) {
    updateNoteId(note, data.noteCssId);
    updateNoteText(note, data.text);
    updateNoteGroupName(note, data.groupName);
    if (data.dataset && Object.keys(data.dataset).length > 1) {
      setNoteDataset(note, data.dataset);
    } else {
      updateNoteGroupId(note, data.groupId);
      updateNotePatchUrl(note, data.patchUrl);
    }
    updateNoteDeleteUrl(note, data.deleteUrl);
    if (data.style) {
      setNoteStyle(note, data.style);
    } else {
      updateNoteCoords(note, data.coords);
      updateNoteColor(note, data.color);
      updateNoteZIndex(note, data.zIndex);
    }
    if (data.prevData) setNotePrevData(note, data.prevData);
  }

  var getNoteText = function(note) {
    return note.find(".note-text").text();
  }
  var updateNoteText = function(note, text) {
    if (!text) return;
    note.find(".note-text").text(text);
  }
  var getNoteGroupName = function(note) {
    return note.find(".note-group-name select").val() ||
    note.find(".note-group-name").text();
  }
  var updateNoteGroupName = function(note, groupName) {
    if (!groupName) return;
    userView() ? note.find(".note-group-name").text(groupName) :
    updateAdminNoteGroupSelect(note, groupName);
  }
  var getNoteColor = function(note) {
    return note.find("input.colorpicker").val();
  }
  var updateNoteColor = function(note, color) {
    if (!color) return;
    note
      .css("background-color", color)
      .find(".color-style")
      .css("background-color", color);
    note.find("input.colorpicker").val(color);
  }
  var getNoteCoords = function(note) {
    var x = note.css("left");
    var y = note.css("top");
    return `${x}:${y}`;
  }
  var updateNoteCoords = function(note, coords) {
    if (!coords) return;
    var x = parseInt(coords.split(":")[0]);
    var y  = parseInt(coords.split(":")[1]);
    note.css("left", x).css("top", y);
  }
  var getNoteZIndex = function(note) {
    return note.css("z-index");
  }
  var updateNoteZIndex = function(note, zIndex) {
    if (!zIndex) return;
    note.css("z-index", zIndex);
  }
  var getNoteDataset = function(note) {
    var dataset = {};
    var noteDataset = note.get()[0].dataset;
    for (key in noteDataset) {
      dataset[key] = noteDataset[key];
    }
    return dataset;
  }
  var setNoteDataset = function(note, dataset) {
    if (!dataset) return;
    for (key in dataset) {
      var attr = `data-${key.replace(/([A-Z])/g, "-$1").toLowerCase()}`;
      note.attr(attr, dataset[key]);
    }
  }
  var getNotePrevData = function(note) {
    var data = {};
    var noteData = note.data();
    for (key in noteData) {
      data[key] = noteData[key];
    }
    return data;
  }
  var setNotePrevData = function(note, data) {
    if (!data) return;
    for (key in data) {
      note.data(key, data[key]);
    }
  }
  var getNoteStyle = function(note) {
    return note.attr("style");
  }
  var setNoteStyle = function(note, style) {
    if (!style) return;
    note.attr("style", style);
  }

  var getNotePatchUrl = function(note) {
    return note.attr("data-url");
  }
  var updateNotePatchUrl = function(note, url) {
    if (!url) return;
    note.attr("data-url", url);
  }
  var getNoteDeleteUrl = function(note) {
    return note.find(".delete").attr("data-url");
  }
  var updateNoteDeleteUrl = function(note, url) {
    if (!url) return;
    note.find(".delete").attr("data-url", url);
  }

  var getNoteId = function(note) {
    return note.attr("id");
  }
  var updateNoteId = function(note, cssId) {
    if (!cssId) return;
    note.attr("id", cssId);
  }
  var getNoteGroupId = function(note) {
    return note.attr("data-group-id");
  }
  var updateNoteGroupId = function(note, groupId) {
    if (!groupId) return;
    note
      .attr("data-group-id", groupId)
      .find("[data-group-id]").each(function() {
        $(this).attr("data-group-id", groupId);
      });
  }

  var updateAdminNoteGroupSelect = function(note, groupName) {
    if (!groupName) return;
    note.find(".note-group-name select").val(groupName);
    if (note.data("selectmenuInstalled")) {
      note.find(".note-group-name select").selectmenu("refresh");
    } else {
      note.find(".tools .note-group-name select").selectmenu({
        change: function(e) {
          updateNote.call(this);
        }
      });
      note.data("selectmenuInstalled", true);
    }
  }
  
  // ----------------------------------------------------------------------
  // NOTE CRUD

  var createNote = function(success) {
    var url = $(".add-note").attr("data-url");
    $.ajax({
      url: url,
      type: "GET",
      processData: false,
      dataType: "JSON",
      contentType: "application/json",
      success: function(result) {
        note = newNoteFromData(convertResultToNoteData(result));
        bringToFront.call(note);
        if (success) success(result, note);
      },
      error: function() {
        alert("something went wrong -- ask Kevin");
      }
    });
  };

  var newNoteFromData = function(noteData) {
    // clone(false): do not clone event handlers, they are installed afterwards
    var note = $("#note-template .note").first().clone(false);
    updateNoteFromData(note, noteData);
    $("#notes-container").append(note);
    initializeNote(note);
    return note;
  }

  var updateNote = function(e) {
    var note = $(this).closest(".note");
    var data = getDataForUpdateNote(note);
    if (!data) return;
    var url = note.attr("data-url");
    var token = note.attr("data-token");
    flashHide(note);
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
        flashSuccess(note);
        result.model.text = null; // NB: do not overwrite text while user is typing
        updateNoteFromData(note, convertResultToNoteData(result));
        setPrevDataForUpdateNote(note);
      }, function() {
        flashError(note);
      }
    });
  }

  var deleteNote = function(e) {
    var note = $(this).closest(".note");
    flashHide(note);
    deleteThis.call(this, e,
      function() {
        note.remove();
      },
      function() {
        flashError(note)
      }
    );
  }

  var convertResultToNoteData = function(result) {
    return {
      noteCssId: `note-${result.model.id}`,
      id: result.model.id,
      text: result.model.text,
      groupName: result.group_name,
      groupId: result.model.survey_group_id,
      color: result.color,
      coords: result.model.coords,
      zIndex: result.model.z_index,
      patchUrl: result.patch_url,
      deleteUrl: result.delete_url
    };
  }
  
  var getDataForUpdateNote = function(note) {
    var data = {};
    if (getNoteText(note) != note.data("prevText")) data.text = getNoteText(note);
    if (getNoteGroupName(note) != note.data("prevGroupName")) data.group_name = getNoteGroupName(note);
    if (getNoteColor(note) != note.data("prevColor")) data.group_color = getNoteColor(note);
    if (getNoteCoords(note) != note.data("prevCoords")) data.coords = getNoteCoords(note);
    if (getNoteZIndex(note) != note.data("prevZIndex")) data.z_index = getNoteZIndex(note);
    return Object.keys(data).length == 0 ? null : data;
  }

  var setPrevDataForUpdateNote = function(note) {
    note.data("prevText", getNoteText(note));
    note.data("prevGroupName", getNoteGroupName(note));
    note.data("prevColor", getNoteColor(note));
    note.data("prevCoords", getNoteCoords(note));
    note.data("prevZIndex", getNoteZIndex(note));
  }

  // ----------------------------------------------------------------------
  // NOTE DRAGGING

  var onDragStart = function(target, x, y) {
    if (userView()) return;
    // if command key held down
    //   replace the target with a new note
    //   and drag the new note
    var draggedNote = $(target);
    flashHide(draggedNote);
    if (metaKeyDown) {
      createNote(function(result, newNote) {
        // drag the new note instead of the target
        // leave the target where it was
        // do this by swapping the vital data between the two
        // make the group the same between the two since the user expects this behavior
        var newNoteData = getNoteData(newNote);
        var draggedNoteData = getNoteData(draggedNote);
        newNoteData.groupName = draggedNoteData.groupName;
        newNoteData.groupId = draggedNoteData.groupId;
        newNoteData.style = draggedNoteData.style; // includes color and coords (and z-index)
        draggedNoteData.zIndex = getNoteZIndex(newNote);
        newNoteData.zIndex = getNoteZIndex(draggedNote);
        updateNoteFromData(newNote, draggedNoteData);
        updateNoteFromData(draggedNote, newNoteData);
      });
    }
  }

  var onDragEnd = function(target, x, y) {
    var note = $(target).closest(".note");
    updateNoteCoords(note, `${x}:${y}`);
    if (userView()) return;
    updateNote.call(target);
  }

  var bringToFront = function() {
    var note = $(this);
    var zIndex = 0;
    $(".note").each(function() {
      var thisZIndex = parseInt($(this).css("z-index"));
      if (thisZIndex > zIndex) zIndex = thisZIndex;
    })
    if (parseInt(getNoteZIndex(note)) >= zIndex) return;
    updateNoteZIndex(note, zIndex+1);
    if (userView()) return;
    updateNote.call(note);
  }


  // ----------------------------------------------------------------------
  // NOTE COLORPICKER

  var initializeColorPicker = function(note) {
    var cpInput = note.querySelector("input.colorpicker");
    var picker = new CP(cpInput);
    var button = note.querySelector("button.colorpicker");
    // picker.on("blur", () => {});
    picker.on("focus", () => {});
    button.addEventListener("click", function(e) {
      if (e.target.nodeName != "I") return;
      picker[picker.visible ? "exit" : "enter"](button);
      picker.fit([
        button.offsetLeft - 25,
        button.offsetTop + button.offsetHeight + 50
      ]);
    });
    picker
      .on("change", debounce(updateCPSource, 250))
      .on("change", function(r, g, b, a) {
        var color = this.color(r, g, b, a);
        var note = $(this.source).closest(".note");
        var prevColor = note.data("prevColor");
        var groupId = getNoteGroupId(note);
        $(`.note[data-group-id='${groupId}']`).each(function() {
          var groupNote = $(this);
          updateNoteColor(groupNote, color);
          groupNote.data("prevColor", color);
        });
        note.data("prevColor", prevColor);
      });
  }

  var updateCPSource = function() {
    updateNote.call(this.source);
  }

  // ----------------------------------------------------------------------
  // NOTE INITIALIZATION

  var initializeNote = function(note) {
    var domNote = note.get()[0]; // get underlying dom element
    note
      .find(".vote-up, .vote-down")
      .on("click", processVote);
    note
      .find(".survey-answer-vote")
      .on("dblclick", function(e) {
        e.preventDefault();
        e.stopPropagation();
      });
    note.on("mousedown", bringToFront);
    var domHandler = note.hasClass("move") ? domNote : domNote.querySelector(".move");
    dragmove(domNote, domHandler, onDragStart, onDragEnd);
    if (userView()) return; // stop if user view

    // admin features
    note
      .find(".note-text")
      .on("keydown", debounce(updateNote, 500))
      .on("keydown", function(e) {
        // do not hide flash on control, alt and meta keys
        if (e.key == "Meta" || e.key == "Alt" || e.key == "Control") return;
        flashHide($(this).closest(".note"));
      });
    note
      .find(".delete")
      .on("click", deleteNote);
    updateAdminNoteGroupSelect(note, getNoteGroupName(note));
    setPrevDataForUpdateNote(note);
    initializeColorPicker(domNote);
  }
  
  $("#notes-container .note").each(function() {
    initializeNote($(this));
  });

  // ----------------------------------------------------------------------
  // NOTE LIVE VIEW

  var liveView = function() {
    var liveView = $(".live-view");
    var timestamp = liveView.attr("data-timestamp");
    var url = liveView.attr("data-url");
    if (!url || !timestamp) return;
    $.ajax({
      url: `${url}?timestamp=${timestamp}`,
      type: "GET",
      processData: false,
      dataType: "JSON",
      contentType: "application/json",
      success: function(data, textStatus, jqXHR) {
        liveView.text(jqXHR.status);
        if (jqXHR.status == 304) return;
        // prep for deletion of notes
        $("#notes-container .note").each(function() {
          $(this).data("updated", false);
        });
        // update all notes
        for (result of data.results) {
          var note = $(`#notes-container #note-${result.model.id}`);
          noteData = convertResultToNoteData(result);
          switch (note.length) {
          case 0:
            var newNote = newNoteFromData(noteData);
            newNote.data("updated", true);
            break;
          case 1:
            updateNoteFromData(note, noteData);
            note.data("updated", true);
            break;
          }
        }
        // now remove any deleted notes
        $("#notes-container .note").each(function() {
          if (!$(this).data("updated")) $(this).remove();
        });
        liveView.attr("data-timestamp", data.timestamp);
      }
    });
  }

  // ----------------------------------------------------------------------
  // GLOBAL NOTE LISTENERS

  $("body#notes button.add-note").on("click", function() {
    createNote();
  });

  if ($("#notes-container .live-view")) {
    setInterval(liveView, 2000);
  };

});

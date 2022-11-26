function optShortDateAtTime(tzString) {
  return {
    timeZone: tzString,
    weekday: "short",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "numeric"
  };
}

function optShortDate(tzString) {
  return {
    timeZone: tzString,
    weekday: "short",
    month: "short",
    day: "numeric"
  };
}

function optTimeAndDay(tzString) {
  return {
    timeZone: tzString,
    weekday: "short",
    hour: "numeric",
    minute: "numeric"
  };
}

function optPickerDateTime(tzString) {
  return {
    timeZone: tzString,
    hour12: false,
    year:"numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit"
  };
}

function getFormat(className, tzString) {
  switch(className) {
  case "user-request-date":
    return optShortDate(tzString)
  case "datetime-picker":
    return optPickerDateTime(tzString)
  }
  // default
  return {
    timeZone: tzString,
    dateStyle: "full",
    timeStyle: "short"
  }
}

function convertTZ(datetime, className, tzString) {
  date = new Date((typeof datetime == "string" ? new Date(datetime) : datetime));
  if (date == "Invalid Date") return date;
  return date.toLocaleString("en-US", getFormat(className, tzString)).replace(/\//g, "-");
}

function convertElementTimeFromUTC(el) {
  var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  el = $(el);
  var datetime = (el.val() || el.text()).trim();
  var className = el.attr("class").split(" ")[0];
  datetime = convertTZ(datetime, className, timezone);
  if (datetime == "Invalid Date") return;
  el.text(datetime);
}

function convertTimeFromUTC() {
  $(".utc-time").each( function(i, dom) {
    convertElementTimeFromUTC(dom);
  });
};

function convertTimeToUTC() {
  var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  $(".utc-time").each( function(i, dom){
    dom = $(dom);
    var link = dom.find("a");
    datetime = link.text().trim();
    className = dom.attr("class").split(" ")[0];
    datetime = convertTZ(datetime, className, timezone);
    if (datetime === "Invalid Date") return;
    link.text(datetime);
  })
};
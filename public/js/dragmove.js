// https://github.com/knadh/dragmove.js
// Kailash Nadh (c) 2020.
// MIT License.

// dragmove(target, handler, onStart(target, x, y), onEnd(target, x, y)).
// onStart and onEnd are optional callbacks that receive target element, and x, y coordinates.
// example:
// dragmove(document.querySelector("#box"), document.querySelector("#box .drag-handle"), onStart, onEnd);
// where:
// onStart(target, lastX, lastY);
// onEnd(target, parseInt(target.style.left), parseInt(target.style.top));

let _loaded = false;
let _callbacks = [];
const _isTouch = window.ontouchstart !== undefined;

////////////////////////////////////////////////////
// Drag Delay
// Returns a function, that, as long as it continues to be invoked, will not
// be triggered. The function will be called after it stops being called for
// `wait` milliseconds. If `immediate = true` is passed, trigger the function
// on the leading edge, instead of the trailing.
var dragDelay = function(func, wait, immediate) {
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


var dragmove = function(target, handler, onStart, onEnd) {
  // Register a global event to capture mouse moves (once).
  if (!_loaded) {
    document.addEventListener(_isTouch ? "touchmove" : "mousemove", function(e) {
      let c = e.touches ? e.touches[0] : e;

      // On mouse move, dispatch the coords to all registered callbacks.
      for (callback of _callbacks) {
        callback(c.clientX, c.clientY);
      }
    });
  }

  _loaded = true;
  let dragging = hasStarted = delayDone = onStartFired = false;
  let deltaX = deltaY = holdDeltaX = holdDeltaY = lastX = lastY = 0;

  // On the first click and hold, record the offset of the target in relation
  // to the point of the click
  handler.addEventListener(_isTouch ? "touchstart" : "mousedown", function(e) {
    // e.stopPropagation();
    // e.preventDefault();
    if (target.dataset.dragEnabled === "false") return;

    let c = e.touches ? e.touches[0] : e;
    lastX = lastY = 0;

    dragging = !e.touches; // delay dragging only for touch interface, to allow for scrolling
    hasStarted = true;

    dragDelay(function() {
      if (dragging) return;
      dragging = (lastX == 0 && lastY == 0);
    }, 333)();

    deltaX = c.clientX - target.offsetLeft;
    deltaY = c.clientY - target.offsetTop;
  });

  // On leaving click, stop moving.
  document.addEventListener(_isTouch ? "touchend" : "mouseup", function(e) {   
    if (onEnd && hasStarted) {
      onEnd(target, parseInt(target.style.left), parseInt(target.style.top));
    }

    dragging = hasStarted = onStartFired = false;
  });
  // Register mouse-move callback to determine if touch is held (moving v. scrolling)
  _callbacks.push(function move(x, y) {
    if (!hasStarted) return;
    lastX = x - deltaX;
    lastY = y - deltaY;
  });

  // Register mouse-move callback to move the element.
  _callbacks.push(function move(x, y) {
    if (!dragging) return;

    if (onStart && !onStartFired) {
      onStart(target, lastX, lastY);
      onStartFired = true;
    }

    // If boundary checking is on, don't let the element cross the viewport.
    if (target.dataset.dragBoundary === "true") {
      lastX = Math.min(window.innerWidth - target.offsetWidth, Math.max(0, lastX));
      lastY = Math.min(window.innerHeight - target.offsetHeight, Math.max(0, lastY));
    }

    target.style.left = lastX + "px";
    target.style.top = lastY + "px";
  });
}

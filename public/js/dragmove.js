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
  let isMoving = false, hasStarted = false;
  let deltaX = 0, deltaY = 0, lastX = 0, lastY = 0;

  // On the first click and hold, record the offset of the target in relation
  // to the point of the click
  handler.addEventListener(_isTouch ? "touchstart" : "mousedown", function(e) {
    e.stopPropagation();
    e.preventDefault();
    if (target.dataset.dragEnabled === "false") return;

    let c = e.touches ? e.touches[0] : e;

    isMoving = true;
    deltaX = c.clientX - target.offsetLeft;
    deltaY = c.clientY - target.offsetTop;
  });

  // On leaving click, stop moving.
  document.addEventListener(_isTouch ? "touchend" : "mouseup", function(e) {   
    if (onEnd && hasStarted) {
      onEnd(target, parseInt(target.style.left), parseInt(target.style.top));
    }

    isMoving = false;
    hasStarted = false;
  });

  // Register mouse-move callback to move the element.
  _callbacks.push(function move(x, y) {
    if (!isMoving) {
      return;
    }

    if (!hasStarted) {
      hasStarted = true;
      if (onStart) {
        onStart(target, lastX, lastY);
      }
    }

    lastX = x - deltaX;
    lastY = y - deltaY;

    // If boundary checking is on, don't let the element cross the viewport.
    if (target.dataset.dragBoundary === "true") {
      lastX = Math.min(window.innerWidth - target.offsetWidth, Math.max(0, lastX));
      lastY = Math.min(window.innerHeight - target.offsetHeight, Math.max(0, lastY));
    }

    target.style.left = lastX + "px";
    target.style.top = lastY + "px";
  });
}

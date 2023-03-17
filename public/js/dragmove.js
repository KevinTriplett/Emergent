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

let _callbacks = [];
let _loadedDM = isDragging = false;
const _isTouch = window.ontouchstart !== undefined;

var dragmove = function(target, handler, onStart, onEnd) {
  // Register a global event to capture mouse moves (once).
  if (!_loadedDM) {
    document.addEventListener(_isTouch ? "touchmove" : "mousemove", function(e) {
      let c = e.touches ? e.touches[0] : e;
      // On mouse move, dispatch the coords to all registered callbacks.
      for (callback of _callbacks) {
        callback(c.clientX, c.clientY);
      }
    });
  }

  _loadedDM = true;
  let deltaX = deltaY = lastX = lastY = 0;

  var trackDrag = function(x, y) {    // If boundary checking is on, don't let the element cross the viewport.
    if (target.dataset.dragBoundary === "true") {
      lastX = Math.min(window.innerWidth - target.offsetWidth, Math.max(0, lastX));
      lastY = Math.min(window.innerHeight - target.offsetHeight, Math.max(0, lastY));
    }
    lastX = x - deltaX;
    lastY = y - deltaY;
    target.style.left = `${lastX}px`;
    target.style.top = `${lastY}px`;
  }

  // On the first click and hold, record the offset of the target in relation
  // to the point of the click
  handler.addEventListener(_isTouch ? "touchstart" : "mousedown", function(e) {
    if (target.dataset.dragEnabled === "false") return;
    e.stopPropagation();
    e.preventDefault();
    
    // callback for start of drag
    if (onStart) onStart(target, lastX, lastY);

    let c = e.touches ? e.touches[0] : e;
    deltaX = c.clientX - target.offsetLeft;
    deltaY = c.clientY - target.offsetTop;
    
    // register callback to track the drag
    _callbacks.push(trackDrag);
    isDragging = true;
  });

  // On leaving click, stop moving, call onEnd and remove callbacks
  document.addEventListener(_isTouch ? "touchend" : "mouseup", function(e) {   
    if (onEnd && isDragging) onEnd(target, parseInt(target.style.left), parseInt(target.style.top));
    _callbacks.length = 0;
    isDragging = false;
  });
}

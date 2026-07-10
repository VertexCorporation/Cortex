Node.js provides the `events` modules, which provides `EventEmitter`.  This modules provides `EventListener`,
an object that can listen for events.

This was heavily inspired by [Backbone](http://backbonejs.org/)'s `listenTo()` and `stopListening()` functions.
The idea is to make it easy to de-regster an event listener when you're done with it.

Supports Node.js 0.12 and up.

Event Listener Memory Leaks
===========================

```js
import EventEmitter from 'events';

class Widget() {
    constructor(emitter) {
        emitter.on('error', err => this.close());
    }
    ...
}

let emitter = new EventEmitter();

let widget = new Widget(emitter);
// Do some stuff with `widget`.  When we're done with it, clear the reference to
// `widget` so the garbage collector can free it.
widget = null;
```

The code above creates a pretty common memory leak in node.js apps; the problem in the above is that when we call
`emitter.on('error', ...)`, we add the function we pass in to the EventEmitter's list of events to call, which
means EventEmitter has a reference to the handler function.  But, the handler function is an arrow function,
which binds `this`, which means the handler function has a reference to `widget`.  When we set `widget = null`,
the `Widget` object will never be garbage collected, because `emitter` still has a reference to it.

One way to solve this problem is to call `emitter.removeListener('error', handler)`, but note that the function
we passed to `emitter.on(...)` was not `this.close()`, so we can't call `emitter.removeListener('error', this.close)`.
We need to keep a reference to the anonymous arrow function we passed in to `emitter.on()`.

`EventListener`'s job is to keep track of these references for you:


```js
import EventEmitter from 'events';
import EventListener from 'events-listener';

class Widget() {
    constructor(emitter) {
        this.listener = new EventListener();
        this.listener.listenTo(emitter, 'error', err => this.close());
    }

    destroy() {
        this.listener.stopListening();
    }
    ...
}

let emitter = new EventEmitter();

let widget = new Widget(emitter);

// Do some stuff with `widget`.

widget.destroy();
widget = null;
```



API
===

### class EventListener

#### EventListener.listenTo(emitter, event, handler)

Similar to calling `emitter.on(event, handler)`.

#### EventListener.listenToOnce(emitter, event, handler)

Similar to calling `emitter.once(event, handler)`.

#### EventListener.stopListening([emitter,] [event,] [handler]);

Stop listening to some or all events that were registered with calls to `listenTo()` or `listenToOnce()`.

If all three arguments are passed, this is similar to calling `emitter.removeListener(handler)`.

If no arguments are passed, then this will remove all listeners that have been registered on this listener.
If an `emitter` is passed, this will remove all listeners that have been registered on the specific emitter.
If `emitter` and `event` are passed, then this will remove all listeners from the specific emitter that were
registered for the specific event.

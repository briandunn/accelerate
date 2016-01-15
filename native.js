Native = {}
Native.start = function(app) {
  var context    = new webkitAudioContext,
      gain       = context.createGain(),
      oscillator = context.createOscillator();

  oscillator.connect(gain);
  gain.connect(context.destination);

  app.ports.note.subscribe(function(note) {
    oscillator.frequency.value = note;
  });

  app.ports.mute.subscribe(function(mute) {
    gain.gain.value = mute ? 0 : 1;
  });

  document.getElementById('accelerate').addEventListener('click', function(event){
    oscillator.start(0);
  });

  window.addEventListener('devicemotion', function(event){
    var
      x = event.acceleration.x,
      y = event.acceleration.y,
      z = event.acceleration.z;
    if(x && y && z)
      app.ports.acceleration.send({x:x,y:y,z:z});
  },true);
};

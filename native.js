Native = {}
Native.start = function(app) {
  var context = new webkitAudioContext;
  var oscillator = context.createOscillator();
  oscillator.connect(context.destination);

  app.ports.note.subscribe(function(note) {
    oscillator.frequency.value = note;
  });

  document.getElementById('go').addEventListener('click', function(event){
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

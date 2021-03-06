//Variables
ArrayList<grid> grids = new ArrayList<grid>();
ArrayList<room> rooms = new ArrayList<room>();
ArrayList<Integer> doors = new ArrayList<Integer>();
int cell_size=16;
boolean isrunning=false;
boolean generate=false;

void setup()
{
  //Render settings
  size(1280, 720);
  frameRate(60);
  rectMode(CENTER);
  noStroke();

  //setupgenerate();
  thread("setupgenerate");
}

void keyReleased()
{
  if (isrunning==false)
    setup();
}

void setupgenerate()
{
  grids.clear();
  //Create cells
  for (int b=0; b<=41; b++)
  {
    for (int a=0; a<=74; a++)
    {
      grids.add(new grid(a+(cell_size*a), b+(cell_size*b)));
    }
  }
  loop();

  //Map generation
  generate();
}

void draw()
{
  clear();
  background(0);

  //Draw map
  for (int a=0; a<grids.size(); a++)
  {
    grids.get(a).draw();
  }
  //Draw room text
  for (int a=0; a<rooms.size(); a++)
  {
    rooms.get(a).draw();
  }
}

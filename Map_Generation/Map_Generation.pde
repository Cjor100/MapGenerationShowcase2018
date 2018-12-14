//Variables
ArrayList<grid> grids = new ArrayList<grid>();
ArrayList<room> rooms = new ArrayList<room>();
ArrayList<Integer> doors = new ArrayList<Integer>();
int cell_size=16;

void keyReleased()
{
  generate();
}

void setup()
{
  //Render settings
  size(1280, 720);
  frameRate(60);
  rectMode(CENTER);
  noStroke();

  //Map generation
  generate();
  //thread("generate");
}

void draw()
{
  clear();
  background(0);

  //Render map
  for (int a=0; a<grids.size(); a++)
  {
    grids.get(a).draw();
  }
}

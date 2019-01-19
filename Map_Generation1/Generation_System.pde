//Cells
class grid
{
  //Variables
  boolean blocked=true;
  boolean room=false;
  boolean door=false;
  boolean delete=false;
  int x, y;
  int r, g, b;
  int state = 0;
  grid(int x_, int y_)
  {
    x = x_;
    y = y_;
  }
  void draw()
  {
    if (blocked)
    {
      if (door)
        fill(255, 255, 0);
      else
        fill(0);
    } else
    {
      fill(r, g, b);
    }
    rect(x, y, cell_size, cell_size);
  }
}

class room
{
  //Variables
  int x, y, x2, y2, id;
  ArrayList<Integer> connections = new ArrayList<Integer>();
  ArrayList<Float> distances = new ArrayList<Float>();
  ArrayList<Integer> path = new ArrayList<Integer>();

  room(int x_, int y_, int x2_, int y2_)
  {
    x = x_;
    y = y_;
    x2 = x2_;
    y2 = y2_;
  }

  void destroy()
  {
    for (int b=x; b<=x2; b++)
    {
      for (int c=y; c<=y2; c++)
      {
        grids.get((c*75)+b).state=0;
        grids.get((c*75)+b).blocked=true;
        grids.get((c*75)+b).room=false;
      }
    }
  }
}

void generate()
{
  ArrayList<Integer> path = new ArrayList<Integer>();
  ArrayList<Integer> closed = new ArrayList<Integer>(); //Connected rooms
  rooms.clear();
  doors.clear();
  path.clear();
  closed.clear();
  grids.clear();

  //Create cells
  for (int b=0; b<=41; b++)
  {
    for (int a=0; a<=74; a++)
    {
      grids.add(new grid(a+(cell_size*a), b+(cell_size*b)));
    }
  }

  //Room Generation
  for (int a=0; a<=200; a++)
  {
    int x = (int) random(1, 70);
    int x2 = (int) (x+(random(4, 10)));
    if (x2>73)
      x2=73;
    int y = (int) random(1, 37);
    int y2 = (int) (y+(random(4, 10))); 
    if (y2>40)
      y2=40;
    if (grids.get((y*75)+x).blocked==false)
      continue;
    if (grids.get((y2*75)+x2).blocked==false)
      continue;
    boolean breakout=false;
    for (int b=x-1; b<=x2+1; b++)
    {
      for (int c=y-1; c<=y2+1; c++)
      {
        if (grids.get((c*75)+b).blocked==false)
        {
          breakout=true;
          break;
        }
      }
      if (breakout)
        break;
    }
    if (breakout)
      continue;
    for (int b=x; b<=x2; b++)
    {
      for (int c=y; c<=y2; c++)
      {
        grids.get((c*75)+b).state=2;
        grids.get((c*75)+b).blocked=false;
        grids.get((c*75)+b).room=true;
        grids.get((c*75)+b).r=255;
        grids.get((c*75)+b).g=255;
        grids.get((c*75)+b).b=255;
      }
    }

    //Registering new room
    rooms.add(new room(x, y, x2, y2));
  }

  //Connect all rooms
  closed.add(0);
  int lastsize=0;
  for (int a=0; a<closed.size(); a++)
  {
    //Find the closest room that isnt closed
    int closest=-1;
    for (int b=0; b<rooms.size(); b++)
    {
      if (closed.contains(b))
        continue;
      if (closest==-1)
        closest=b;
      else if (dist(rooms.get(closed.get(a)).x, rooms.get(closed.get(a)).y, rooms.get(b).x, rooms.get(b).y)<dist(rooms.get(closed.get(a)).x, rooms.get(closed.get(a)).y, rooms.get(closest).x, rooms.get(closest).y))
      {
        closest=b;
      }
    }
    if (closest==-1)
      continue;

    //Get closest path
    int gx1 = -1;
    int gy1 = -1;
    int gx2 = -1;
    int gy2 = -1;
    for (int b=rooms.get(closed.get(a)).x; b<=rooms.get(closed.get(a)).x2; b++)
    {
      for (int c=rooms.get(closed.get(a)).y; c<=rooms.get(closed.get(a)).y2; c++)
      {
        for (int d=rooms.get(closest).x; d<=rooms.get(closest).x2; d++)
        {
          for (int e=rooms.get(closest).y; e<=rooms.get(closest).y2; e++)
          {
            if (gx1==-1)
            {
              gx1=b;
              gy1=c;
              gx2=d;
              gy2=e;
            } else if (dist(b, c, d, e)<dist(gx1, gy1, gx2, gy2))
            {
              gx1=b;
              gy1=c;
              gx2=d;
              gy2=e;
            }
          }
        }
      }
    }

    //Carve out path
    grids.get((gy2*75)+gx2).state=1;
    path=pathfind((gy1*75)+gx1, (gy2*75)+gx2, 2);
    if (path.size()>10 || path.size()==1)
    {
      if (lastsize!=closed.size())
      {
        lastsize=closed.size();
        a=0;
      }
      continue;
    }
    for (int b=0; b<path.size(); b++)
    {
      grids.get(path.get(b)).state=2;
      grids.get(path.get(b)).blocked=false;
      grids.get(path.get(b)).r=255;
      grids.get(path.get(b)).g=255;
      grids.get(path.get(b)).b=255;
      if (grids.get(path.get(b)).room==false)
      {
        grids.get(path.get(b)).door=true;
        grids.get(path.get(b)).blocked=true;
        doors.add(path.get(b));
      }
    }

    //Close off room
    closed.add(closest);

    //delay(200);
  }
  for (int b=0; b<rooms.size(); b++)
  {
    if (closed.contains(b))
      continue;
    else
      rooms.get(b).destroy();
  }
  if (closed.size()<12)
    generate();
}

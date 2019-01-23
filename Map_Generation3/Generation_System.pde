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
  void move(int x_, int y_)
  {
    x+=x_*speed;
    y+=y_*speed;
  }
  void snap(float x_, float y_)
  {
    x+=x_;
    y+=y_;
  }
}

class bonus
{
  //Variables
  int id;
  bonus(int id_)
  {
    id=id_;
  }
}

class room
{
  //Variables
  int x, y, x2, y2, id, distance;
  boolean mainpath, bonus, teleporter, boss, bossadjacent = false;
  ArrayList<Integer> connections = new ArrayList<Integer>();
  ArrayList<Float> distances = new ArrayList<Float>();
  ArrayList<Integer> path = new ArrayList<Integer>();

  room(int x_, int y_, int x2_, int y2_)
  {
    x = x_;
    y = y_;
    x2 = x2_;
    y2 = y2_;
    distance = 0;
    id = rooms.size();
  }

  boolean checkteleporter()
  {
    for (int a=0; a<connections.size(); a++)
    {
      for (int b=0; b<rooms.size(); b++)
      {
        if (rooms.get(b).id==connections.get(a))
          if (rooms.get(b).teleporter==true)
            return true;
      }
    }
    return false;
  }

  void draw()
  {
    textAlign(CENTER, CENTER);
    fill(0);
    if (distance==0)
      text("Spawn", x+(x*cell_size)+32, y+(y*cell_size));
    if (boss)
      text("Boss", x+(x*cell_size)+32, y+(y*cell_size)+32);
    if (bonus)
      text("Bonus", x+(x*cell_size)+32, y+(y*cell_size)+16);
    if (teleporter)
      text("Teleporter", x+(x*cell_size)+32, y+(y*cell_size)+32);
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

  void removeconnection(int room)
  {
    for (int a=0; a<connections.size(); a++)
    {
      if (connections.get(a)==room)
      {
        connections.remove(a);
        break;
      }
    }
  }
}

void generate()
{
  isrunning=true;
  ArrayList<Integer> path = new ArrayList<Integer>();
  ArrayList<Integer> closed = new ArrayList<Integer>(); //Connected rooms
  ArrayList<bonus> bonusrooms = new ArrayList<bonus>();
  bonusrooms.clear();
  rooms.clear();
  doors.clear();
  path.clear();
  closed.clear();

  while (rooms.size()<12)
  {
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
      delay(10);
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

      //Mark the connections
      rooms.get(rooms.get(closest).id).connections.add(rooms.get(closed.get(a)).id);
      rooms.get(rooms.get(closed.get(a)).id).connections.add(rooms.get(closest).id);

      //Add distance
      rooms.get(closest).distance=rooms.get(closed.get(a)).distance+1;

      delay(10);
    }

    //Cleanup any unconnected rooms
    for (int b=0; b<rooms.size(); b++)
    {
      if (closed.contains(b))
        continue;
      else
        rooms.get(b).destroy();
      delay(10);
    }
  }

  //Start placing mechanics in the world
  //Iterate through all rooms until the biggest distance is, mark the said room as the boss room
  int boss = 0;
  int farthest = 0;
  for (int a=0; a<rooms.size(); a++)
  {
    if (rooms.get(a).distance>farthest)
    {
      farthest=rooms.get(a).distance;
      boss=a;
    }
  }
  rooms.get(boss).boss=true;
  rooms.get(boss).mainpath=true;
  rooms.get(0).mainpath=true;
  int current=boss;
  while (current!=0)
  {
    for (int a=0; a<rooms.get(current).connections.size(); a++)
    {
      if (rooms.get(rooms.get(current).connections.get(a)).distance==rooms.get(current).distance-1)
      {
        current=rooms.get(rooms.get(current).connections.get(a)).id;
        ;
        rooms.get(current).mainpath=true;
        break;
      }
    }
  }

  //Untill the amount of bonus objects is 2 or we run out of branching paths, place a bonus object on any rooms not marked as the main path that only has one connection, mark said connections as main path
  for (int a=0; a<rooms.size(); a++)
  {
    if (rooms.get(a).connections.size()==1 && rooms.get(a).boss==false && rooms.get(a).distance!=0)
    {
      bonusrooms.add(new bonus(rooms.get(a).id));
      rooms.get(a).bonus=true;
      current=a;
      while (current!=0)
      {
        int smallest=rooms.get(rooms.get(current).connections.get(0)).distance;
        int connection=rooms.get(rooms.get(current).connections.get(0)).id;
        for (int b=0; b<rooms.get(current).connections.size(); b++)
        {
          if (rooms.get(rooms.get(current).connections.get(b)).distance<smallest)
          {
            smallest=rooms.get(rooms.get(current).connections.get(b)).distance;
            connection=rooms.get(rooms.get(current).connections.get(b)).id;
          }
        }
        current=connection;
        rooms.get(current).mainpath=true;
      }
      rooms.get(a).mainpath=true;
      if (bonusrooms.size()==2)
        break;
    }
    delay(10);
  }

  //Remove any rooms that are not on the main path and are not marked as bonus
  for (int a=0; a<rooms.size(); a++)
  {
    if (rooms.get(a).mainpath==false)
    {
      for (int b=0; b<rooms.size(); b++)
      {
        rooms.get(b).removeconnection(rooms.get(a).id);
      }
      rooms.get(a).destroy();
      rooms.remove(a);
      a=0;
    } else
      continue;
    delay(10);
  }

  //Restart generation if rooms size is not met
  if (rooms.size()<12)
  {
    isrunning=false;
    noLoop();
    delay(1000);
    setupgenerate();
  }

  //Grid cleanup
  //todo remake, it causes some weird issues with paths that have a width of two, as well as some paths will linger when close to rooms
  //todo remake how connections are defined, every path could have a connection id so it could be removed when that connection is no longer there
  for (int a=0; a<grids.size(); a++)
  {
    if (grids.get(a).door==false)
      continue;

    ArrayList<Integer> adjacent = new ArrayList<Integer>();
    adjacent.clear();
    if (grids.get(a-1).door==true || grids.get(a-1).room==true)//left
      adjacent.add(a-1);
    if (grids.get(a+1).door==true || grids.get(a+1).room==true)//right
      adjacent.add(a+1);
    if (grids.get(a-75).door==true || grids.get(a-75).room==true)//left
      adjacent.add(a-75);
    if (grids.get(a+75).door==true || grids.get(a+75).room==true)//right
      adjacent.add(a+75);

    if (adjacent.size()<2)
    {
      grids.get(a).door=false;
      a=0;
    }
    delay(1);
  }

  //if the amount of bonus objects is greater than 0, place a teleporter adjacent to the boss room
  if (bonusrooms.size()>0)
  {
    for (int a=0; a<rooms.size(); a++)
    {
      if (rooms.get(a).connections.contains(boss))
        rooms.get(a).teleporter=true;
    }
  }

  //if the amount of bonus objects is less than 2, place a bonus object adjacent to the boss room
  if (bonusrooms.size()<2)
  {
    for (int a=0; a<rooms.size(); a++)
    {
      if (rooms.get(a).connections.contains(boss))
      {
        rooms.get(a).bonus=true;
        break;
      }
    }
  }

  //if a room has more than 3 connections and is not adjacent to a teleporter, create a teleporter
  for (int a=0; a<rooms.size(); a++)
  {
    if (rooms.get(a).checkteleporter()==false && rooms.get(a).connections.size()>=3)
    {
      rooms.get(a).teleporter=true;
    }
  }

  //if the amount of bonus objects is less than 2 and the amount of teleporters is not 0, place a bonus object adjacent to a teleporter
  if (bonusrooms.size()<2)
  {
    for (int a=0; a<rooms.size(); a++)
    {
      if (rooms.get(a).checkteleporter()==true)
      {
        rooms.get(a).bonus=true;
        break;
      }
    }
  }

  isrunning=false;
  noLoop();
  delay(1000);
  setupgenerate();
}

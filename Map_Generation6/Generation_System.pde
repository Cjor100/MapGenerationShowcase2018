//Cells //<>//
class grid
{
  //Variables
  boolean blocked=true;
  boolean room=false;
  boolean door=false;
  boolean delete=false;
  boolean bonus=false;
  boolean teleporter=false;
  int pathid=-1;
  int connection1 = -1;
  int connection2 = -1;
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
    if (room)
      fill(255, 255, 255);
    if (blocked)
    {
      if (connection1!=-1)
      {
        fill(255, 0, 0);
      } else
        fill(r, g, b);
    }
    if (bonus || teleporter)
      fill(r, g, b);
    //if (state==1)
    //  fill(0, 255, 0);
    //if (state==2 && room==false && door==false)
    //  fill(0, 0, 255);
    //fill(r, g, b);
    rect(x, y, cell_size, cell_size);
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

class teleporter
{
  //Variables
  int id;
  teleporter(int id_)
  {
    id=id_;
  }
}

class room
{
  //Variables
  int x, y, x2, y2, id;
  int distance=-1;
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
    id = rooms.size();
  }

  //Checks if any of the rooms connections have a teleporter
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
        grids.get((c*75)+b).blocked=true;
        grids.get((c*75)+b).room=false;
        grids.get((c*75)+b).r=0;
        grids.get((c*75)+b).b=0;
        grids.get((c*75)+b).g=0;
      }
    }
  }

  void setState(int state)
  {
    for (int b=x; b<=x2; b++)
    {
      for (int c=y; c<=y2; c++)
      {
        grids.get((c*75)+b-74).state=state;
        grids.get((c*75)+b-75).state=state;
        grids.get((c*75)+b-76).state=state;
        grids.get((c*75)+b-1).state=state;
        grids.get((c*75)+b).state=state;
        grids.get((c*75)+b+1).state=state;
        grids.get((c*75)+b+74).state=state;
        grids.get((c*75)+b+75).state=state;
        grids.get((c*75)+b+76).state=state;
      }
    }
  }

  //Removes connections of rooms that no longer exist
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

  //Interior Generation
  void generate()
  {
    ArrayList<Integer> neutralgrids = new ArrayList<Integer>();
    ArrayList<Integer> doors = new ArrayList<Integer>();
    //Reclassifying grids
    for (int b=x; b<=x2; b++)
    {
      grids.get(((y-1)*75)+b).state=0;
      grids.get(((y2+1)*75)+b).state=0;
    }
    for (int b=y; b<=y2; b++)
    {
      grids.get((b*75)+(x-1)).state=0;
      grids.get((b*75)+(x2+1)).state=0;
    }

    //Grid classification
    for (int b=x; b<=x2; b++)
    {
      for (int c=y; c<=y2; c++)
      {
        if (grids.get((c*75)+b).door==true)
          doors.add((c*75)+b);
        else
          neutralgrids.add((c*75)+b);
      }
    }

    //Wall Placement
    for (int a=0; a<(int)random(2, 12); a++)
    {
      int random = (int)random(0, neutralgrids.size()-1);
      grids.get(neutralgrids.get(random)).state=0;
      boolean breakout=false;
      for (int b=0; b<neutralgrids.size(); b++)
      {
        for (int c=0; c<doors.size(); c++)
        {
          if (pathfind(neutralgrids.get(b), doors.get(c), 0).size()==1)
          {
            breakout=true;
            break;
          }
        }
        if (breakout)
          break;
      }
      if (breakout)
      {
        grids.get(neutralgrids.get(random)).state=2;
        a--;
        continue;
      }
      grids.get(neutralgrids.get(random)).blocked=true;
      grids.get(neutralgrids.get(random)).r=50;
      grids.get(neutralgrids.get(random)).g=50;
      grids.get(neutralgrids.get(random)).b=50;
      neutralgrids.remove(random);
    }
  }
}

void generate()
{
  println("generation start");
  isrunning=true;
  ArrayList<Integer> path = new ArrayList<Integer>();
  ArrayList<Integer> closed = new ArrayList<Integer>(); //Connected rooms
  ArrayList<bonus> bonusrooms = new ArrayList<bonus>();
  ArrayList<teleporter> teleporters = new ArrayList<teleporter>();
  bonusrooms.clear();
  teleporters.clear();
  rooms.clear();
  doors.clear();
  path.clear();
  closed.clear();

  print("room placement");
  delay(500);
  //Room Generation
  for (int a=0; a<200; a++)
  {
    //Generating random parameters for room placement
    int x = (int) random(1, 70);
    int x2 = (int) (x+7);
    if (x2>73)
      x2=73;
    int y = (int) random(1, 37);
    int y2 = (int) (y+7); 
    if (y2>40)
      y2=40;
    boolean breakout=false;
    for (int b=x-2; b<=x2+2; b++)
    {
      if (b<=0 || b>=75)
      {
        breakout=true;
        break;
      }
      for (int c=y-2; c<=y2+2; c++)
      {
        if (c<=0 || c>=42)
        {
          breakout=true;
          break;
        }
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

    //Drawing room
    for (int b=x; b<=x2; b++)
    {
      for (int c=y; c<=y2; c++)
      {
        grids.get((c*75)+b-74).state=2;
        grids.get((c*75)+b-75).state=2;
        grids.get((c*75)+b-76).state=2;
        grids.get((c*75)+b-1).state=2;
        grids.get((c*75)+b).state=2;
        grids.get((c*75)+b+1).state=2;
        grids.get((c*75)+b+74).state=2;
        grids.get((c*75)+b+75).state=2;
        grids.get((c*75)+b+76).state=2;
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

  print(", connect rooms");
  delay(500);
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

    grids.get((gy2*75)+gx2-75).state=1;
    grids.get((gy2*75)+gx2-1).state=1;
    grids.get((gy2*75)+gx2).state=1;
    grids.get((gy2*75)+gx2+1).state=1;
    grids.get((gy2*75)+gx2+75).state=1;

    grids.get((gy1*75)+gx1-75).state=1;
    grids.get((gy1*75)+gx1-1).state=1;
    grids.get((gy1*75)+gx1).state=1;
    grids.get((gy1*75)+gx1+1).state=1;
    grids.get((gy1*75)+gx1+75).state=1;
    //delay(100);
    path=pathfind((gy1*75)+gx1, (gy2*75)+gx2, 2);
    rooms.get(closed.get(a)).setState(2);
    rooms.get(closest).setState(2);
    if (path.size()>10 || path.size()==1)
    {
      if (lastsize!=closed.size())
      {
        lastsize=closed.size();
        a=0;
      }
      continue;
    }
    int red, green, blue;
    red=(int)random(50, 255);
    green=(int)random(50, 255);
    blue=(int)random(50, 255);
    for (int b=0; b<path.size(); b++)
    {
      grids.get(path.get(b)-75).state=2;
      grids.get(path.get(b)-2).state=2;
      grids.get(path.get(b)-1).state=2;
      grids.get(path.get(b)).state=2;
      grids.get(path.get(b)+1).state=2;
      grids.get(path.get(b)+2).state=2;
      grids.get(path.get(b)+75).state=2;
      if (path.get(b)-150>=0)
        grids.get(path.get(b)-150).state=2;
      if (path.get(b)+150<=3150)
        grids.get(path.get(b)+150).state=2;
      grids.get(path.get(b)).connection1=rooms.get(closed.get(a)).id;
      grids.get(path.get(b)).connection2=rooms.get(closest).id;
      grids.get(path.get(b)).pathid=a;
      grids.get(path.get(b)).r=red;
      grids.get(path.get(b)).g=green;
      grids.get(path.get(b)).b=blue;
      grids.get(path.get(b)).door=true;
      if (grids.get(path.get(b)).room==false)
      {
        grids.get(path.get(b)).blocked=true;
        doors.add(path.get(b));
        delay(10);
      }
    }

    //Close off room
    closed.add(closest);

    //Mark the connections
    rooms.get(rooms.get(closest).id).connections.add(rooms.get(closed.get(a)).id);
    rooms.get(rooms.get(closed.get(a)).id).connections.add(rooms.get(closest).id);

    //Add distance
    rooms.get(closest).distance=rooms.get(closed.get(a)).distance+1;

    //Restart
    a=0;
  }

  //Restart generation if rooms size is not met
  if (closed.size()<12)
  {
    noLoop();
    delay(1000);
    println();
    println("Not enough connected rooms, restarting");
    setupgenerate();
  }

  print(", unconnected cleanup");
  delay(500);
  //Cleanup any unconnected rooms
  for (int b=0; b<rooms.size(); b++)
  {
    if (closed.contains(b))
      continue;
    else
    {
      rooms.get(b).destroy();
      delay(10);
    }
  }

  print(", boss placement");
  delay(500);
  //Start placing mechanics in the world
  //Iterate through all rooms until the biggest distance is, mark the said room as the boss room
  int boss = 0;
  int farthest = 0;
  //Find the farthest room from the spawn, based on the amount of steps
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
        rooms.get(current).mainpath=true;
        break;
      }
    }
  }

  print(", bonus placement");
  delay(500);
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
      if (bonusrooms.size()>=2)
        break;
    }
  }

  print(", room cleanup");
  delay(500);
  //Remove any rooms that are not on the main path and are not marked as bonus as long as there is more then 12 rooms
  for (int a=0; a<rooms.size(); a++)
  {
    if (rooms.size()>12)
    {
      if (rooms.get(a).mainpath==false && rooms.get(a).connections.size()==1)
      {
        for (int b=0; b<rooms.size(); b++)
        {
          rooms.get(b).removeconnection(rooms.get(a).id);
        }
        //Remove path connections
        for (int b=0; b<grids.size(); b++)
        {
          if (grids.get(b).connection1==rooms.get(a).id || grids.get(b).connection2==rooms.get(a).id)
          {
            //grids.get(b-150).state=0;
            //grids.get(b-75).state=0;
            //grids.get(b-2).state=0;
            //grids.get(b-1).state=0;
            //grids.get(b).state=0;
            //grids.get(b+1).state=0;
            //grids.get(b+2).state=0;
            //grids.get(b+75).state=0;
            //grids.get(b+150).state=0;
            grids.get(b).door=false;
            grids.get(b).connection1=-1;
            grids.get(b).connection2=-1;
            grids.get(b).r=0;
            grids.get(b).g=0;
            grids.get(b).b=0;
            delay(10);
          }
        }
        rooms.get(a).destroy();
        rooms.remove(a);
        a=0;
      }
    }
  }

  print(", path widening");
  delay(500);
  //Increase the width of paths
  for (int a=0; a<grids.size(); a++)
  {
    if (grids.get(a).pathid!=-1 && grids.get(a).connection1!=-1)
    {
      int b=1;
      if (grids.get(a+b).room==false && grids.get(a+b).pathid==-1)
      {
        grids.get(a+b).door=true;
        grids.get(a+b).pathid=grids.get(a).pathid;
        grids.get(a+b).r=grids.get(a).r;
        grids.get(a+b).g=grids.get(a).g;
        grids.get(a+b).b=grids.get(a).b;
        delay(10);
      }
      if (grids.get(a-b).room==false && grids.get(a-b).pathid==-1)
      {
        grids.get(a-b).door=true;
        grids.get(a-b).pathid=grids.get(a).pathid;
        grids.get(a-b).r=grids.get(a).r;
        grids.get(a-b).g=grids.get(a).g;
        grids.get(a-b).b=grids.get(a).b;
        delay(10);
      }

      b=75;
      if (grids.get(a+b).room==false && grids.get(a+b).pathid==-1)
      {
        grids.get(a+b).door=true;
        grids.get(a+b).pathid=grids.get(a).pathid;
        grids.get(a+b).r=grids.get(a).r;
        grids.get(a+b).g=grids.get(a).g;
        grids.get(a+b).b=grids.get(a).b;
        delay(10);
      }
      if (grids.get(a-b).room==false && grids.get(a-b).pathid==-1)
      {
        grids.get(a-b).door=true;
        grids.get(a-b).pathid=grids.get(a).pathid;
        grids.get(a-b).r=grids.get(a).r;
        grids.get(a-b).g=grids.get(a).g;
        grids.get(a-b).b=grids.get(a).b;
        delay(10);
      }
    }
  }

  print(", teleporter placement");
  delay(500);
  //if the amount of bonus objects is greater than 0, place a teleporter adjacent to the boss room
  if (bonusrooms.size()>0)
  {
    for (int a=0; a<rooms.size(); a++)
    {
      if (rooms.get(a).connections.contains(boss))
      {
        teleporters.add(new teleporter(rooms.get(a).id));
        rooms.get(a).teleporter=true;
        delay(10);
      }
    }
  }

  print(", bonus placement");
  delay(500);
  //if the amount of bonus objects is less than 2, place a bonus object adjacent to the boss room
  if (bonusrooms.size()<2)
  {
    for (int a=0; a<rooms.size(); a++)
    {
      if (rooms.get(a).connections.contains(boss))
      {
        bonusrooms.add(new bonus(rooms.get(a).id));
        rooms.get(a).bonus=true;
        delay(10);
        break;
      }
    }
  }

  print(", teleporter placement");
  delay(500);
  //if a room has more than 3 connections and is not adjacent to a teleporter, create a teleporter
  for (int a=0; a<rooms.size(); a++)
  {
    if (rooms.get(a).checkteleporter()==false && rooms.get(a).connections.size()>=3)
    {
      rooms.get(a).teleporter=true;
      delay(10);
    }
  }

  //if the amount of bonus objects is less than 2 and the amount of teleporters is not 0, place a bonus object adjacent to a teleporter
  if (bonusrooms.size()<2)
  {
    for (int a=0; a<rooms.size(); a++)
    {
      if (rooms.get(a).checkteleporter()==true)
      {
        bonusrooms.add(new bonus(rooms.get(a).id));
        rooms.get(a).bonus=true;
        delay(10);
        break;
      }
    }
  }

  print(", bonus placement");
  delay(500); 
  //if the amount of bonus objects is still less than 2 and the amount of teleporters is not 0, place a bonus object adjacent to a teleporter
  if (bonusrooms.size()<2)
  {
    for (int a=0; a<rooms.size(); a++)
    {
      if (rooms.get(a).distance==0)
      {
        bonusrooms.add(new bonus(rooms.get(a).id));
        rooms.get(a).bonus=true;
        delay(10);
        break;
      }
    }
  }

  print(", teleporter placement");
  delay(500);
  //Check if there are any dead ends that are not marked as bonus room or boss, if there are create a teleporter as long as they are not adjacent to a teleporter
  for (int a=0; a<rooms.size(); a++)
  {
    if (rooms.get(a).connections.size()>1)
      continue;
    if (rooms.get(a).bonus==false && rooms.get(a).boss==false && rooms.get(a).checkteleporter()==true)
    {
      rooms.get(a).teleporter=true;
    }
  }

  println(", interior placement");
  delay(500);
  //Check if there are any dead ends that are not marked as bonus room or boss, if there are create a teleporter as long as they are not adjacent to a teleporter
  for (int a=0; a<rooms.size(); a++)
  {
      rooms.get(a).generate();
  }

  println("generation complete");
  isrunning=false;
  noLoop();
  delay(2000);
  setupgenerate();
  while (generate==false)
  {
    delay(10);
  }
  generate=false;
  setupgenerate();
}

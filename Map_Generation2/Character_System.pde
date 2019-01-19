//Variables
boolean right, left, up, down;
boolean attemptright, attemptleft, attemptup, attemptdown;

void keyPressed()
{
  if (keyCode == 65)
    attemptleft = true;
  if (keyCode == 68)
    attemptright = true;
  if (keyCode == 87)
    attemptup = true;
  if (keyCode == 83)
    attemptdown = true;
}

void keyReleased()
{
  if (isrunning==false)
    setup();
  //thread("setup");
  if (keyCode == 65)
    attemptleft = false;
  if (keyCode == 68)
    attemptright = false;
  if (keyCode == 87)
    attemptup = false;
  if (keyCode == 83)
    attemptdown = false;
}

class player
{
  int xdirection, ydirection, x, y;
  player()
  {
  }
  void update()
  {
    //Assign x and y
    x=width/2;
    y=height/2;

    //Movement assignment
    left=attemptleft;
    right=attemptright;
    up=attemptup;
    down=attemptdown;

    //Check collisions
    for (int a=0; a<grids.size(); a++)
    {
      if (grids.get(a).blocked==false)
        continue;
      if (dist(x, y, grids.get(a).x, grids.get(a).y)<=64)
      {
        if (dist(x, 0, grids.get(a).x-54, 0)<=speed && (x)<(grids.get(a).x))
          right=false;
        if (dist(x, 0, grids.get(a).x+54, 0)<=speed && (x)>(grids.get(a).x))
          left=false;
        if (dist(y, 0, grids.get(a).y+54, 0)<=speed && (y)>(grids.get(a).y))
          up=false;
        if (dist(y, 0, grids.get(a).y-54, 0)<=speed && (y)<(grids.get(a).y))
          down=false;
      }
    }

    //Assign directions
    if (right)
      xdirection=-1;
    else if (left)
      xdirection=1;
    else
      xdirection=0;
    if (up)
      ydirection=1;
    else if (down)
      ydirection=-1;
    else
      ydirection=0;

    //Update map
    for (int a=0; a<grids.size(); a++)
    {
      grids.get(a).move(xdirection, ydirection);
    }

    //Check Doors
    for (int a=0; a<doors.size(); a++)
    {
      if (dist(x, y, grids.get(doors.get(a)).x, grids.get(doors.get(a)).y)<64)
      {
        grids.get(doors.get(a)).delete=true;
        for (int b=0; b<doors.size(); b++)
        {
          for (int c=0; c<doors.size(); c++)
          {
            if (dist(grids.get(doors.get(b)).x, grids.get(doors.get(b)).y, grids.get(doors.get(c)).x, grids.get(doors.get(c)).y)<128 && grids.get(doors.get(b)).delete==true && grids.get(doors.get(c)).delete==false)
            {
              grids.get(doors.get(c)).delete=true;
              b=0;
              c=0;
              break;
            }
          }
        }
        for (int b=0; b<doors.size(); b++)
        {
          if (grids.get(doors.get(b)).delete==true)
          {
            grids.get(doors.get(b)).blocked=false;
            grids.get(doors.get(b)).door=false;
            doors.remove(b);
            b--;
          }
        }
        break;
      }
    }
  }
  void draw()
  {
    //Draw player
    fill(255, 0, 0);
    rect((x), (y), 32, 32);
  }
}

class Timer
{
public:
  Timer() {}
};

class TimeKeeper
{
public:
  TimeKeeper(Timer t) : timer(t) {}

private:
  Timer timer;
};

int main()
{
  // What looks like a variable declaration is actually interpreted
  // as a function declaration!
  TimeKeeper timeKeeper(Timer());

  // Fix by use uniform initialization syntax
  TimeKeeper timeKeeper2{Timer{}}; // This works as intended
}

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

final int N = 5;
final int HUNGRY = 0;
final int EATING = 1;
final int THINKING = 2;

public class Monitor {

  public Lock lock;
  public Condition[] conditions;

  public int n;
  public int[] state;
  public int[] philosophers;

  public Monitor(int N) {

    n = N;

    lock = new ReentrantLock();
    conditions = new Condition[N];
    state = new int[N];
    philosophers = new int[N];

    for (int i = 0; i < N; i++) {
      state[i] = THINKING;
      philosophers[i] = i;
      conditions[i] = lock.newCondition();
    }
  }

  public int leftPhilosopher(int philosopherNumber) {
    return (philosopherNumber+(n-1)) % n;
  }

  public int rightPhilosopher(int philosopherNumber) {
    return (philosopherNumber+1) % n;
  }

  public void picksUpForks(int philosopherNumber) {

    lock.lock();

    state[philosopherNumber] = HUNGRY;

    if (state[philosopherNumber] == HUNGRY
      && state[leftPhilosopher(philosopherNumber)] != EATING
      && state[rightPhilosopher(philosopherNumber)] != EATING) {
    } else {

      try {
        conditions[philosopherNumber].await();
      }
      catch(InterruptedException e) {
        e.printStackTrace();
      }
    }

    state[philosopherNumber] = EATING;
    println("Philosopher", philosopherNumber+1, "takes forks.");
    println("Philosopher", philosopherNumber+1, "is eating.");

    lock.unlock();
  }

  public void putsDownForks(int philosopherNumber) {

    lock.lock();

    state[philosopherNumber] = THINKING;

    int left = leftPhilosopher(philosopherNumber);
    int left2 = leftPhilosopher(left);
    if (state[left] == HUNGRY && state[left2] != EATING) {
      conditions[left].signal();
    }

    int right = rightPhilosopher(philosopherNumber);
    int right2 = rightPhilosopher(right);
    if (state[right] == HUNGRY && state[right2] != EATING) {
      conditions[right].signal();
    }

    println("Philosopher", philosopherNumber, "is putting down forks.");

    lock.unlock();
  }
}

public class Philosopher implements Runnable {

  public int pid;

  public Monitor monitor;
  public Thread thread;

  public Philosopher(int pidArg, Monitor monitorArg) {
    pid = pidArg;
    monitor = monitorArg;

    thread = new Thread(this);
    thread.start();
  }

  @Override
    public void run() {

    while (true) {
      monitor.picksUpForks(pid);
      eat();
      monitor.putsDownForks(pid);
    }
  }

  public void eat() {
    println("Philosopher", pid+1, "eats.");
    try {
      Thread.sleep(500); // 500[ms] = 0.5[s]
    }
    catch(InterruptedException e) {
      e.printStackTrace();
    }
  }
}

void setup() {

  println("Start dinner.");

  Philosopher[] philosophers = new Philosopher[N];
  Monitor monitor = new Monitor(N); // Share this monitor with philosophers.
  for (int i = 0; i < N; i++) {
    philosophers[i] = new Philosopher(i, monitor);
  }

  /*
  for (int i = 0; i < N; i++) {
   try {
   philosophers[i].thread.join();
   }
   catch(InterruptedException e) {
   e.printStackTrace();
   }
   }
   println("End dinner.");
   */
}

/*
 * 🎄 🎁 🎅 🎁 🎄
 */
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

// philosophers
final int N = 5;

// state
final int HUNGRY = 0;
final int EATING = 1;
final int THINKING = 2;

public class Monitor {

  public Lock lock;
  public Condition[] conditions;

  public int n;
  public int[] status;
  public int[] philosophers;

  public Monitor(int N) {

    n = N;

    lock = new ReentrantLock();
    conditions = new Condition[N];
    status = new int[N];
    philosophers = new int[N];

    for (int i = 0; i < N; i++) {
      status[i] = THINKING;
      philosophers[i] = i;
      conditions[i] = lock.newCondition();
    }
  }

  // e.g. {0,1,...,n-1} left(k)->k-1 left(0)->n-1
  public int leftPhilosopher(int philosopherNumber) {
    return (philosopherNumber+(n-1)) % n;
  }

  // e.g. {0,1,...,n-1} right(k)->k+1 right(n-1)->0
  public int rightPhilosopher(int philosopherNumber) {
    return (philosopherNumber+1) % n;
  }

  public void picksUpForks(int philosopherNumber) {

    lock.lock();


    // test
    // It(philosopherNumber) wants to eating.
    // but it has to wait eating left(right) philosopher.
    status[philosopherNumber] = HUNGRY;

    if(!( status[philosopherNumber] == HUNGRY
          && status[leftPhilosopher(philosopherNumber)] != EATING
        && status[rightPhilosopher(philosopherNumber)] != EATING)){
      try {
        conditions[philosopherNumber].await();
      }
      catch(InterruptedException e) {
        e.printStackTrace();
      }
    }

    status[philosopherNumber] = EATING;
    println("Philosopher", philosopherNumber, "takes forks.");
    println("Philosopher", philosopherNumber, "is eating.");

    lock.unlock();
  }

  public void putsDownForks(int philosopherNumber) {

    lock.lock();


    // test
    // When this time, left(right) philosopher wants to start eating.
    // Therefore, it(philosopherNumber) puts down forks and sends a signal.
    // Finally, it starts thinking.
    status[philosopherNumber] = THINKING;

    int left = leftPhilosopher(philosopherNumber);
    int left2 = leftPhilosopher(left);
    if (status[left] == HUNGRY && status[left2] != EATING) {
      conditions[left].signal();
    }

    int right = rightPhilosopher(philosopherNumber);
    int right2 = rightPhilosopher(right);
    if (status[right] == HUNGRY && status[right2] != EATING) {
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
    println("Philosopher", pid, "eats.");
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
  Monitor monitor = new Monitor(N); // Share this Monitor with philosophers.
  for (int i = 0; i < N; i++) {
    philosophers[i] = new Philosopher(i, monitor);
  }

  // You have to enable this code if you want philosopher' to stop eating in finite-time.
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

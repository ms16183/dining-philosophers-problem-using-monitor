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
  public Condition conditions;

  public int n;
  public int[] status;
  public int[] philosophers;

  public Monitor(int N) {

    n = N;

    lock = new ReentrantLock();
    conditions = lock.newCondition();
    status = new int[N];
    philosophers = new int[N];

    for (int i = 0; i < N; i++) {
      status[i] = THINKING;
      philosophers[i] = i;
    }
  }

  // e.g. {0,1,...,n-1} left(k)->k-1, left(0)->n-1
  public int leftPhilosopher(int philosopherNumber) {
    return (philosopherNumber+(n-1)) % n;
  }

  // e.g. {0,1,...,n-1} right(k)->k+1, right(n-1)->0
  public int rightPhilosopher(int philosopherNumber) {
    return (philosopherNumber+1) % n;
  }

  public void test(int philosopherNumber) {
    if (status[leftPhilosopher(philosopherNumber)] != EATING
      && status[philosopherNumber] == HUNGRY
      && status[rightPhilosopher(philosopherNumber)] != EATING) {
      status[philosopherNumber] = EATING;
      println("[", millis() / 1000.0, "]", "Philosopher", philosopherNumber, "is eating.");
    }
    // Enable using fork.
    conditions.signal();
  }

  public void picksUpForks(int philosopherNumber) {

    lock.lock();

    // test
    // Being hungry, it(philosopherNumber) wants to eating.
    // But it has to wait if left(right) philosopher has already used fork.
    status[philosopherNumber] = HUNGRY;
    println("[", millis() / 1000.0, "]", "Philosopher", philosopherNumber, "is hungry.");

    test(philosopherNumber);

    if (status[philosopherNumber] != EATING) {
      try {
        conditions.await();
      }
      catch(InterruptedException e) {
        e.printStackTrace();
      }
    }
    lock.unlock();
  }

  public void putsDownForks(int philosopherNumber) {

    lock.lock();

    // It(philosopherNumber) wants to start thinking.
    // Therefore, It(philosopherNumber) sends a signal to left(right) philosopher.
    status[philosopherNumber] = THINKING;
    println("[", millis() / 1000.0, "]", "Philosopher", philosopherNumber, "is thinking.");

    test(leftPhilosopher(philosopherNumber));
    test(rightPhilosopher(philosopherNumber));

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

    try {
      Thread.sleep(1000);
    }
    catch(InterruptedException e) {
      e.printStackTrace();
    }
  }
}

void setup() {

  println("[", millis() / 1000.0, "]", "Dinning is started.");

  Philosopher[] philosophers = new Philosopher[N];
  Monitor monitor = new Monitor(N); // Share this Monitor with philosophers.
  for (int i = 0; i < N; i++) {
    philosophers[i] = new Philosopher(i, monitor);
  }

  // You have to enable under code if you want philosopher' to stop eating in finite-time.
  /*
  for (int i = 0; i < N; i++) {
   try {
   philosophers[i].thread.join();
   }
   catch(InterruptedException e) {
   e.printStackTrace();
   }
   }
   println("Dinning is ended.");
   */
}

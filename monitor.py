#!/usr/bin/env python3
from threading import Thread, Condition, RLock
import time

# state
HUNGRY = 0
EATING = 1
THINKING = 2

class Monitor:

    def __init__(self, n):
        self.n = n
        self.lock = RLock()
        self.conditions = [Condition() for i in range(self.n)]
        self.status = [THINKING for i in range(self.n)]
        self.philosophers = [i for i in range(self.n)]


    def __left(self, pid):
        return (pid + (self.n-1)) % self.n


    def __right(self, pid):
        return (pid + 1) % self.n


    def __test(self, pid):
        if self.status[self.__left(pid)] != EATING and self.status[self.__right(pid)] != EATING and self.status[pid] == HUNGRY:
            self.status[pid] = EATING
            print(pid, "EATING")

        try:
            self.conditions[pid].notify()
        except:
            pass


    def pickup(self, pid):
        with self.lock:
            self.status[pid] = HUNGRY
            print(pid, "HUNGRY")

            self.__test(pid)

            if self.status[pid] == THINKING or self.status[pid] == HUNGRY:
                try:
                    self.conditions[pid].wait()
                except:
                    pass


    def putdown(self, pid):
        with self.lock:
            self.status[pid] = THINKING
            print(pid, "THINKING")

            self.__test(self.__left(pid))
            self.__test(self.__right(pid))



class Philosopher:

    def __init__(self, pid, monitor):
        self.pid = pid
        self.monitor = monitor

        self.thread = Thread(target=self.dine)
        self.thread.start()


    def dine(self):
        while True:
            self.monitor.pickup(self.pid)
            self.eat()
            self.monitor.putdown(self.pid)
            self.think()


    def eat(self):
        time.sleep(1)


    def think(self):
        pass



class Table:

    def __init__(self):
        self.n = 5
        # Share this Monitor.
        self.monitor = Monitor(self.n)
        self.philosophers = [Philosopher(i, self.monitor) for i in range(self.n)]



if __name__ == "__main__":
    table = Table()


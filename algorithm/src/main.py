from infrastructure.factories.manager_factory import ManagerFactory
import time

def main():
    ManagerFactory.create_all()
    
    print("Starting Algorithm Service... ")
    print("Listening for frames from shared memory...")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Stopping Algorithm Service...")

if __name__ == "__main__":
    main()

Oracle PL/SQL Disque(Redis) tcp client library.

### Preface

Sometimes it is necessary to inform the client application of changes in the API. You can wait for a direct connection from the client or immediately send a notification to all.

As possible solutions typically use DBMS_PIPE, DBMS_SCHEDULER, DBMS_ALERT.
All this successfully works in the case of a thick client is connected through Oracle driver.

Thin clients easier to synchronize through a Message Queuing server.
This server can be implemented by pl/sql and java module. Add scheduler and paint the table alerts. But in any case, will be faced with the problem of limiting the number of incoming connections. And the load on the server with the database to grow very strongly. Thus, I believe that the Message Queuing server is better to endure beyond the database. 

### Implementation

As sample, I am now trying to use Discue(Redis) solution.
Thin client sets the blocking call GETJOB. Database via scheduler sends a message to all clients through non-blocking calls ADDJOB.
If at this point the customer has dropped from the network, the next connection message is delivered.


### Installation

Install through **install.sql** and set permissions through **permission.sql**.
Examples of use in the demos folder.

### Feedback/Updates

If you have suggestions, comments, or you know how to do best - write.

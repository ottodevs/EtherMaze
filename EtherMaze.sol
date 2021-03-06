pragma solidity ^0.4.17;

import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract EtherMaze {
    
    using strings for *;
    
    enum Direction { West, East, South, North }
    
    struct Player
    {
        bool isRegistered;
        Position position;
    }
    
    struct Position
    {
        uint x;
        uint y;
    }
    
    uint mazeSize;
    uint8[] mazeDescr;
    Position initPos;
    Position treasurePos;
    bool treasureIsFound;
    address winner;
    
    mapping (address => Player) players;

    event log(string s);
    
    function EtherMaze(uint size, uint initX, uint initY, uint treasureX, uint treasureY, uint8[] descr) payable
    {
        //this.maze = maze;
        mazeSize = size;
        mazeDescr = descr;
        initPos.x = initX;
        initPos.y = initY;
        treasurePos.x = treasureX;
        treasurePos.y = treasureY;
    }
    
    function StringToDirection(string s) internal returns (Direction)
    {
        if (sha3(s) == sha3("West"))
            return EtherMaze.Direction.West;
        if (sha3(s) == sha3("East"))
            return EtherMaze.Direction.East;
        if (sha3(s) == sha3("North"))
            return EtherMaze.Direction.North;
        if (sha3(s) == sha3("South"))
            return EtherMaze.Direction.South;
    }
    
    function addressToString(address x) internal returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }
    
    function CanGo(Direction direction) internal returns (bool canGo)
    {
        Position cell = players[msg.sender].position;
        if (direction == EtherMaze.Direction.West && cell.x == 0
            || direction == EtherMaze.Direction.East && cell.x == mazeSize - 1
            || direction == EtherMaze.Direction.North && cell.y == 0
            || direction == EtherMaze.Direction.South && cell.y == mazeSize - 1)
            return false;
        if (direction == EtherMaze.Direction.West)
            return mazeDescr[(mazeSize - 1) * cell.y + cell.x - 1] > 0;
        if (direction == EtherMaze.Direction.East)
            return mazeDescr[(mazeSize - 1) * cell.y + cell.x] > 0;
        if (direction == EtherMaze.Direction.North)
            return mazeDescr[(mazeSize - 1) * (mazeSize) + (mazeSize - 1) * cell.x + cell.y - 1] > 0;
        if (direction == EtherMaze.Direction.South)
            return mazeDescr[(mazeSize - 1) * (mazeSize) + (mazeSize - 1) * cell.x + cell.y] > 0;
    }
    
    function CanGoToString(Direction direction) internal returns (string canGo)
    {
        if (CanGo(direction))
            return "OK";
        else
            return "NO";
    }
    
    function LookAround() constant returns (string around)
    {
        if(!players[msg.sender].isRegistered)
            return "Not Registered";
        var res = "West:";
        res = res.toSlice().concat(CanGoToString(EtherMaze.Direction.West).toSlice());
        res = res.toSlice().concat(" ; East:".toSlice());
        res = res.toSlice().concat(CanGoToString(EtherMaze.Direction.East).toSlice());
        res = res.toSlice().concat(" ; North:".toSlice());
        res = res.toSlice().concat(CanGoToString(EtherMaze.Direction.North).toSlice());
        res = res.toSlice().concat(" ; South:".toSlice());
        res = res.toSlice().concat(CanGoToString(EtherMaze.Direction.South).toSlice());
        return res;
    }
    
    function FoundTreasure() internal returns (bool)
    {
        Position cell = players[msg.sender].position;
        if (cell.x == treasurePos.x && cell.y == treasurePos.y)
            return true;
        else
            return false;
    }
    
    function GetTreasure() internal
    {
        msg.sender.send(this.balance);
        treasureIsFound = true;
        winner = msg.sender;
    }
    
    function Move(Direction direction) internal returns (bool hasMoved)
    {
        Position cell = players[msg.sender].position;
        if (!CanGo(direction))
            return false;
        if (direction == EtherMaze.Direction.West)
            cell.x--;
        if (direction == EtherMaze.Direction.East)
            cell.x++;
        if (direction == EtherMaze.Direction.North)
            cell.y--;
        if (direction == EtherMaze.Direction.South)
            cell.y++;
            
        if (FoundTreasure())
            GetTreasure();
        
        return true;
    }
    
    function Register()
    {
        players[msg.sender].isRegistered = true;
        players[msg.sender].position.x = initPos.x;
        players[msg.sender].position.y = initPos.y;
    }
    
    function GoWest() returns (string around)
    {
        if(treasureIsFound)
        {
        	log("This maze is empty. The treasure has been found by ".toSlice().concat(addressToString(winner).toSlice()));
            return "This maze is empty. The treasure has been found by ".toSlice().concat(addressToString(winner).toSlice());   
        }
        if(!players[msg.sender].isRegistered)
        {
        	log("Not Registered");
            return "Not Registered";
        }
        bool hasMoved = Move(EtherMaze.Direction.West);
        if (!hasMoved)
        	return "Cannot move to this direction";
        if (FoundTreasure())
            return "You found the treasure!!";
        return LookAround();
    }
    
    function GoEast() returns (string around)
    {
        if(treasureIsFound)
        {
        	log("This maze is empty. The treasure has been found by ".toSlice().concat(addressToString(winner).toSlice()));
            return "This maze is empty. The treasure has been found by ".toSlice().concat(addressToString(winner).toSlice());   
        }
        if(!players[msg.sender].isRegistered)
        {
        	log("Not Registered");
            return "Not Registered";
        }
        bool hasMoved = Move(EtherMaze.Direction.East);
        if (!hasMoved)
        	return "Cannot move to this direction";
        if (FoundTreasure())
            return "You found the treasure!!";
        return LookAround();
    }
    
    function GoNorth() returns (string around)
    {
        if(treasureIsFound)
        {
        	log("This maze is empty. The treasure has been found by ".toSlice().concat(addressToString(winner).toSlice()));
            return "This maze is empty. The treasure has been found by ".toSlice().concat(addressToString(winner).toSlice());   
        }
        if(!players[msg.sender].isRegistered)
        {
        	log("Not Registered");
            return "Not Registered";
        }
        bool hasMoved = Move(EtherMaze.Direction.North);
        if (!hasMoved)
        	return "Cannot move to this direction";
        if (FoundTreasure())
            return "You found the treasure!!";
        return LookAround();
    }
    
    function GoSouth() returns (string around)
    {
        if(treasureIsFound)
        {
        	log("This maze is empty. The treasure has been found by ".toSlice().concat(addressToString(winner).toSlice()));
            return "This maze is empty. The treasure has been found by ".toSlice().concat(addressToString(winner).toSlice());   
        }
        if(!players[msg.sender].isRegistered)
        {
        	log("Not Registered");
            return "Not Registered";
        }
        bool hasMoved = Move(EtherMaze.Direction.South);
        if (!hasMoved)
        	return "Cannot move to this direction";
        if (FoundTreasure())
            return "You found the treasure!!";
        return LookAround();
    }

}
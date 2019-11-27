pragma solidity >=0.4.22 <0.6.0;

//1 --> paper
//2 --> Lizard
//3 --> Rock
//4 --> scissors
//5 --> spock


contract Spsls{
    struct Player{
        uint256 lastMove;
        uint256 lastHash;
        uint256 reveal_status;
        uint256 move_status;
        uint256 wins;
    }
    
    uint256 max_games = 10;
    uint256 num_players = 0;
    uint256 no_moves = 0;
    uint256 game_status = 0;
    mapping (uint256 => Player) private player;
    mapping (address => uint256) private player_id;
    function join_game() public returns(uint256 status){
        if (num_players == 2){
            return 0;            
        }
        player_id[msg.sender] = num_players;
        Player memory new_player;
        player[num_players] = new_player;
        new_player.lastHash = 0;
        new_player.reveal_status = 0;
        new_player.move_status = 0;
        num_players += 1;
        return 1;
    }
    
    //Status returns:
    //1: Success;
    //2: Failure;
    function make_move(uint256 move, uint256 passcode) public returns(uint256 status){
        if(no_moves >= max_games)
            return 0;
        uint256 id = player_id[msg.sender];
        if (player[id].move_status == 1)
            return 0;
        player[id].lastHash = uint256(keccak256(abi.encodePacked(passcode,move)));
        player[id].move_status = 1;
        return 1;
    }
    
    function reveal(uint256 move, uint256 passcode) public returns(uint256 status){
        uint256 id = player_id[msg.sender];
        if (player[id].move_status != 1 || player[(id+1)%2].move_status != 1)
            return 0;
        uint256 hash = uint256(keccak256(abi.encodePacked(passcode,move)));
        if(hash != player[id].lastHash){
            return 0;
        }
        player[id].reveal_status = 1;
        player[id].lastMove = move;
        if(player[0].reveal_status == 1 && player[1].reveal_status == 1){
            no_moves += 1;
            player[0].reveal_status = 0;
            player[1].reveal_status = 0;
            player[1].move_status = 0;
            player[0].move_status = 0;
            uint256 winner = get_winner(player[0].lastMove,player[1].lastMove);
            player[winner-1].wins += 1;
        }
        return 1;
    }
    
    function getOpponentScore() public view returns(uint256 score){
        uint256 id = player_id[msg.sender];
        return player[(id+1)%2].wins;
        
    }
    
    function getMyScore() public view returns(uint256 score){
        uint256 id = player_id[msg.sender];
        return player[id].wins;
    }
    
    function get_game_status() public view returns(uint256 status){
        // 0: Game in progress
        // 1: You win
        // 2: You lose
        // 3: Tie
        
        if(no_moves == max_games){
            uint256 id = player_id[msg.sender];
            if(player[0].wins == player[1].wins)
                return 3;
            if(player[id].wins > player[(id+1)%2].wins)
                return 1;
            else
                return 2;
        }
        return 0;
    } 
 
     function get_winner(uint256 choice1,uint256 choice2) private pure returns(uint256 result){
        
             if(choice1 == 1)
            {
                if(choice2==3 || choice2==5)
                   return 1;
                else if(choice2 == 2 || choice2 == 4)
                   return 2;
                else
                    return 3;
            }
            else if(choice1 == 2)
            {
                if(choice2 == 5 || choice2 == 1)
                   return 1;
                else if(choice2 == 3 || choice2 == 4)
                   return 2;
                else
                    return 3;
            }
            else if(choice1 == 3)
            {
                if(choice2 == 4 || choice2 == 2)
                   return 1;
                else if(choice2==1 || choice2==5)
                   return 2;
                else
                    return 3;
            }
            else if(choice1 == 4)
            {
                if(choice2 == 1 || choice2 == 2)
                   return 1;
                else if(choice2==3 || choice2==5)
                   return 2;
                else
                    return 3;
            }
            else
            {
                if(choice2 == 4 || choice2 == 3)
                   return 1;
                else if(choice2==1 || choice2 == 2)
                   return 2;
                else
                    return 3;
            }
    }   
}

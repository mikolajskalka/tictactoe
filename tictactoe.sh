#!/bin/bash

# Initialize variables
save_file="tictactoe_save.txt"

# Initialize the board
initialize_game() {
    board=(" " " " " " " " " " " " " " " " " ")
    current_player="X"
}

# Function to save game
save_game() {
    printf "%s," "${board[@]}" > "$save_file"
    echo "$current_player" >> "$save_file"
    echo "Game saved!"
    sleep 1
}

# Function to load game
load_game() {
    if [[ -f "$save_file" ]]; then
        IFS=',' read -r -a saved_board < "$save_file"
        board=("${saved_board[@]:0:9}")
        current_player="${saved_board[9]}"
        echo "Game loaded!"
        sleep 1
        return 0
    else
        echo "No saved game found!"
        sleep 1
        return 1
    fi
}

# Function to display the board
draw_board() {
    clear
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---+---+---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---+---+---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
    echo ""
    echo "Commands: 1-9 (move), s (save), l (load)"
}

# Function to check for a win
check_win() {
    # Check rows
    for i in 0 3 6; do
        if [[ ${board[$i]} != " " && ${board[$i]} == ${board[$((i+1))]} && ${board[$i]} == ${board[$((i+2))]} ]]; then
            return 0
        fi
    done
    
    # Check columns
    for i in 0 1 2; do
        if [[ ${board[$i]} != " " && ${board[$i]} == ${board[$((i+3))]} && ${board[$i]} == ${board[$((i+6))]} ]]; then
            return 0
        fi
    done
    
    # Check diagonals
    if [[ ${board[0]} != " " && ${board[0]} == ${board[4]} && ${board[0]} == ${board[8]} ]]; then
        return 0
    fi
    if [[ ${board[2]} != " " && ${board[2]} == ${board[4]} && ${board[2]} == ${board[6]} ]]; then
        return 0
    fi
    
    return 1
}

# Function to make a move
make_move() {
    local position=$1
    local index=$((position - 1))
    
    if [[ ${board[$index]} == " " ]]; then
        board[$index]=$current_player
        return 0
    else
        return 1
    fi
}

# Function to switch players
switch_player() {
    if [[ $current_player == "X" ]]; then
        current_player="O"
    else
        current_player="X"
    fi
}

# Main game function
play_game() {
    initialize_game
    while true; do
        draw_board
        read -p "Player $current_player - Enter move or command: " input
        
        case $input in
            [1-9])
                if make_move $input; then
                    if check_win; then
                        draw_board
                        echo "Player $current_player wins!"
                        return
                    fi
                    switch_player
                else
                    echo "Position already taken! Try again"
                    sleep 1
                fi
                ;;
            s|S)
                save_game
                ;;
            l|L)
                load_game
                ;;
            *)
                echo "Invalid input! Use 1-9 for moves, 's' to save, 'l' to load"
                sleep 1
                ;;
        esac
    done
}

# Main game loop with play again feature
while true; do
    play_game
    read -p "Play again? (y/n): " play_again
    if [[ ! $play_again =~ ^[Yy]$ ]]; then
        echo "Thanks for playing!"
        exit 0
    fi
done

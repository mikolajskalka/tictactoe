#!/bin/bash

# Initialize variables
save_file="tictactoe_save.txt"
game_mode=""

# Initialize the game
initialize_game() {
    board=(" " " " " " " " " " " " " " " " " ")
    current_player="X"
    # Ask for game mode at the start
    while [[ ! $game_mode =~ ^[12]$ ]]; do
        echo "Select game mode:"
        echo "1. Single player (vs 'AI')"
        echo "2. Two players"
        read -p "Enter mode (1 or 2): " game_mode
    done
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
    for j in 0 3 6; do
        if [[ ${board[$j]} != " " && ${board[$j]} == ${board[$((j+1))]} && ${board[$j]} == ${board[$((j+2))]} ]]; then
            return 0
        fi
    done
    
    # Check columns
    for j in 0 1 2; do
        if [[ ${board[$j]} != " " && ${board[$j]} == ${board[$((j+3))]} && ${board[$j]} == ${board[$((j+6))]} ]]; then
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

# 'AI' move function
get_ai_move() {
    local move_made=0
    
    # First, try to win
    for i in {0..8}; do
        if [[ ${board[$i]} == " " && $move_made -eq 0 ]]; then
            board[$i]="O"
            if check_win; then
                move_made=1
                break
            fi
            board[$i]=" "
        fi
    done

    # Second, block player's winning move
    if [[ $move_made -eq 0 ]]; then
        for i in {0..8}; do
            if [[ ${board[$i]} == " " ]]; then
                board[$i]="X"
                if check_win; then
                    board[$i]="O"
                    move_made=1
                    break
                fi
                board[$i]=" "
            fi
        done
    fi

    # Take center if available
    if [[ $move_made -eq 0 && ${board[4]} == " " ]]; then
        board[4]="O"
        move_made=1
    fi

    # Take corners if available
    if [[ $move_made -eq 0 ]]; then
        for i in 0 2 6 8; do
            if [[ ${board[$i]} == " " ]]; then
                board[$i]="O"
                move_made=1
                break
            fi
        done
    fi

    # Take any available space
    if [[ $move_made -eq 0 ]]; then
        for i in {0..8}; do
            if [[ ${board[$i]} == " " ]]; then
                board[$i]="O"
                break
            fi
        done
    fi
}

# Single player mode function
play_single_player() {
    local moves_count=0
    while true; do
        draw_board
        
        if [[ $current_player == "X" ]]; then
            read -p "Player $current_player - Enter move or command: " input
            case $input in
                [1-9])
                    if make_move $input; then
                        ((moves_count++))
                        if check_win; then
                            draw_board
                            echo "Player $current_player wins!"
                            return
                        elif ((moves_count == 9)); then
                            draw_board
                            echo "It's a draw!"
                            return
                        fi
                        switch_player
                    else
                        echo "Position already taken! Try again"
                        sleep 1
                    fi
                    ;;
                s|S) save_game ;;
                l|L) load_game ;;
                *)
                    echo "Invalid input! Use 1-9 for moves, 's' to save, 'l' to load"
                    sleep 1
                    ;;
            esac
        else
            echo "'AI' is thinking..."
            sleep 1
            get_ai_move
            ((moves_count++))
            if check_win; then
                draw_board
                echo "'AI' wins!"
                return
            elif ((moves_count == 9)); then
                draw_board
                echo "It's a draw!"
                return
            fi
            switch_player
        fi
    done
}

# Two players mode function
play_multiplayer() {
    local moves_count=0
    while true; do
        draw_board
        read -p "Player $current_player - Enter move or command: " input
        
        case $input in
            [1-9])
                if make_move $input; then
                    ((moves_count++))
                    if check_win; then
                        draw_board
                        echo "Player $current_player wins!"
                        return
                    elif ((moves_count == 9)); then
                        draw_board
                        echo "It's a draw!"
                        return
                    fi
                    switch_player
                else
                    echo "Position already taken! Try again"
                    sleep 1
                fi
                ;;
            s|S) save_game ;;
            l|L) load_game ;;
            *)
                echo "Invalid input! Use 1-9 for moves, 's' to save, 'l' to load"
                sleep 1
                ;;
        esac
    done
}

# Main game function
play_game() {
    initialize_game
    if [[ $game_mode == "1" ]]; then
        play_single_player
    else
        play_multiplayer
    fi
}

# Main game loop
while true; do
    play_game
    read -p "Play again? (y/n): " play_again
    if [[ ! $play_again =~ ^[Yy]$ ]]; then
        echo "Thanks for playing!"
        exit 0
    fi
    clear
    # Reset game mode for next game
    game_mode=""
done

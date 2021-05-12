#!/bin/bash

#	*** Documentation ***
#		* This program would be divided into following modules:
#			* Global Variables
#			* Starting Functions
#			* Game_Play Functions
#			* Win/Lose determining Functions
#			* Utility Functions
#



#	*** Global Variables Start ***
#	Function: Variables to store data that will be used in between the program

current_user=""
total_rounds_won=0
total_rounds_per_mode=4
current_round=0
words_list=()
word=""
puzzle_word=()
word_found=false
current_score=0
current_mode=1
current_mode_name='Easy'
total_rounds=$(( $total_rounds_per_mode * 3 ))


#	*** Global Variables End ***


#	*** Starting Functions Start ***
#	Function: Functions necessary for the initialzation of the components of the game

function main()
{
	clear
	read -p "Enter UserName: " current_user
	menu
}

function menu()
{
	local -i option
	printf "1. Game Difficulty\n2. Score History\n3. Exit\n"
	read -p 'Select Mode: ' option
	case $option in 
		1)
			clear
			game_mode_menu
			;;
		2)
			clear
			display_score_history
			;;
		3)
			exit
			;;
		*)
			printf "Option out of bounds, Please try again!\n"
			;;
	esac
	menu
}

function game_mode_menu()
{
	local -i option
	printf "1. Easy\n2. Medium\n3. Hard\n4. Custom\n"
	read -p 'Select Mode: ' option
	initializer_function $option
}

# <summary>
#	* Player Selects difficulty level of the puzzle
#	* A random word is selected from the list
#	* Program creates a copy of that word and makes a puzzle out of it
#	* Gameplay begins
# </summary>

function initializer_function()
{
	select_game_mode $1
	pick_random_word_from_list
	create_puzzle_string
	game_play
}


# <summary>
#	* A random word is selected from the list
#	* Converts that word from string to array
# </summary>
function pick_random_word_from_list()
{
	list_size=${#words_list[@]}
	word=${words_list[$(( ( RANDOM % $list_size + 1 )))]}
	if [[ -z "${word// }" ]] 
	then
		pick_random_word_from_list
	fi
	convert_string_to_array
}

# <summary>
#	* Creates puzzle from a word, only alphabets would be filled blank
# </summary>
function create_puzzle_string()
{
	half_word_size=$(( ${#word[@]} / 2 ))
	puzzle_word=("${word[@]}")
	for ((i=0; i<half_word_size; i++))
	do
		declare -i index=$(( RANDOM % ${#puzzle_word[@]} ))
		for letter in {a..z}
			do
			if [[ $letter == ${puzzle_word[index]} ]]
			then
				puzzle_word[index]='_'
			fi
		done
	done
	echo ${puzzle_word[@]}
}



#	*** Starting Functions End ***


#	*** Game_Play  Functions Start ***
#	Function: Functions necessary for the initialzation of the components of the game


# <summary>
#	* Prompts a status bar at the top indicating the current puzzle word, currrent difficulty level and current round
#	* Gets alphabet and index from the user and performs its mandatry checks
#	* Checks if the word has any blank spaces left which are yet to be filled
# </summary>
function game_play()
{
	clear
	game_status_bar
	get_input_and_verify
	check_if_blank_spaces_remain
}

# <summary>
#	* Reads the character and searches if the input is an alphabet or not
#	* Prompts the program to then select an index to where the character should be filled
# </summary>
function get_input_and_verify()
{
	local input
	read -p 'Input Alphabet: ' input
	local find_status=false
	for letter in {a..z}
	do
		if [[ $letter == $input ]]
		then
			(( find_status=true ))
			select_index_and_verify $input
			break
		fi
	done
	if [[ $find_status == false ]]
	then
		printf "Input not in range of the alphabets!\n"
		get_input_and_verify
	fi
}

# <summary>
#	* Selects an index from the user where there is blank space and assigns that character to that empty space
# </summary>
function select_index_and_verify()
{
	local -i index
	read -p 'Input Index: ' index
	if (( $index >=0 && $index <= ${#puzzle_word[@]} ))
	then
		if [[ ${puzzle_word[$index]} == '_' ]]
		then
			puzzle_word[$index]=$1
		else
			printf "Index doesnt match a blank space, try again!\n"
			select_index_and_verify $1
		fi
	fi
}

# <summary>
#	* Checks if any blank space remains in the puzzle
#	* If yes it will resume gameplay
#	* If no then it will check if the puzzle is correctly solved or incorrectly
# </summary>
function check_if_blank_spaces_remain()
{
	if [[ ${puzzle_word[@]} =~ "_" ]]
	then
		game_play
	else
		check_if_solved_puzzle_matches			
	fi
}

# <summary>
#	* Selects game difficulty from user/upon the difficulty upgrade by the program
#	* At the selected difficulty it imports the data list from the files
#	* Bonus: It can capture custom data from custom list if user has his/her own word list
# </summary>
function select_game_mode()
{
	case $1 in 
		1)
			mapfile -t words_list < Easy.txt
			current_mode=1
			;;
		2)
			mapfile -t words_list < Medium.txt
			current_mode=2
			;;
		3)
			mapfile -t words_list < Hard.txt
			current_mode=3
			;;
		4)
			mapfile -t words_list < Custom.txt
			current_mode=4
			;;
		*)
			printf "Option out of bounds, Please try again!\n"
			game_mode_menu
			;;
	esac
}


#	*** Game_Play  Functions End ***


#	*** Win/Lose determining  Functions Start ***
#	Function: Functions to determine the winning/losing results of the player


# <summary>
#	* Checks if the puzzle is solved correctly or not
#	* If its solved correctly scores according to the difficulty level will be added
#	* Then it a new puzzle will be assigned for the next round
# </summary>
function check_if_solved_puzzle_matches()
{
	for ((i=0; i<${#word[@]}; i++))
	do
		if [[ ${word[$i]} !=  ${puzzle_word[$i]} ]]
		then
			word_found=false
			(( total_rounds_won++ ))
			echo "Correct Word: ${word[@]}\n"
			break
		else
			word_found=true
		fi
	done
	add_current_score
	iterate_to_next_round
}

# <summary>
#	* A new puzzle will be assigned if a person has completed a round
#	* Difficulty level will be upgraded if a person has completed minimum set of rounds
#	* Difficulty level will not be upgraded if the win to lose ratio of the rounds is smaller than 50%
# </summary>
function iterate_to_next_round()
{
	(( current_round++ ))
	if (( $current_round >= total_rounds_per_mode ))
	then
		current_round=0
		check_if_should_be_promoted_to_next_mode
		if [[ $? == 1 ]]
		then
			printf "Congratulation promoted to next mode!\n"
			(( current_mode++ ))
			if (( $current_mode >= total_rounds_per_mode ))
			then
				results
			fi
		else
			printf "Wind percentage below 60, thus can't be promoted to next round!\n"
		fi
	fi
	word_found=false
	initializer_function $current_mode
}

# <summary>
#	* Adds score according to the difficulty level
# </summary>
function add_current_score()
{
	if [[ $word_found == true ]]
	then
	case $current_mode in 
		1)
			(( current_score+=10 ))
			;;
		2)
			(( current_score+=20 ))
			;;
		3)
			(( current_score+=30 ))
			;;
		*)
			(( current_score+=15 ))
			;;
	esac
	fi
}

# <summary>
#	* Checks if the difficulty level is to be upgraded or not
#	* 50% and above win to lost ratio, the difficulty level will be upgraded
# </summary>
function check_if_should_be_promoted_to_next_mode()
{
	local -i percentage 
	percentage=$(( ( (total_rounds_won + 1) * 100 ) / (total_rounds_per_mode + 1) ))
	if (( $percentage >= 50 ))
	then
		return 1
	fi
	return 0
}



#	*** Win/Lose determining  Functions End ***


#	*** Utility  Functions Start ***
#	Function: Helping functions assisting in the program

function convert_string_to_array()
{
	string=$word
	word=()
	for ((i=0; i<${#string}; i++))
	do
		word[$i]=${string:$i:1}
	done
}

function determine_current_mode()
{
	case $current_mode in 
		1)
			current_mode_name="Easy"
			;;
		2)
			current_mode_name="Medium"
			;;
		3)
			current_mode_name="Hard"
			;;
		4)
			current_mode_name="Custom"
			;;
		*)
			current_mode_name="Unknown"
			;;
	esac
}

function display_alphabets()
{
	echo {a..z}
}

# <summary>
#	* Determines current difficulty mode
#	* Stores global variable data in a file
#	* displays status bar
# </summary>
function game_status_bar()
{
	determine_current_mode
	store_global_variables
	echo "${puzzle_word[@]} 							Current Mode: ${current_mode_name}	Current Score: ${current_score}\n"
}


function results()
{
	game_status_bar
	echo "Total Rounds Won: ${total_rounds_won}/${total_rounds}\n"
	echo "${current_user}		${total_rounds_won}/${total_rounds}\n" >> HighScores.txt
}

function display_score_history()
{
	mapfile score_history < HighScores.txt
	printf "%s" "${score_history[@]}"
	printf "\n"
}

function store_global_variables()
{
	rm TempData
	touch TempData
	echo "${current_user}" >> TempData
	echo "${current_round}" >> TempData
	echo "${current_score}" >> TempData
	echo "${current_mode_name}" >> TempData
	echo "${puzzle_word[@]}" >> TempData
	echo "${word[@]}" >> TempData
	echo "${total_rounds_won}" >> TempData 
	echo "${total_rounds_per_mode}" >> TempData
	echo "${total_rounds}" >> TempData
}

#	*** Utility  Functions End ***

main

#!/bin/bash
# ****************************************
# *** FILE INCLUDES FOLLOWING FUNCTIONS
# *** def_styles   | Line 28
# *** buttonprint  | Line 48
# *** startscreen  | Line 72
# *** game         | Line 118
# *** Difficulty   | Line 163
# *** Prompt       | Line 212
# *** Leaderboard  | Line 253
# *** Main         | Line 285
# ****************************************

#GLOBALS
GTKRC_LOCATION=/home/winepine #Where Our Design File and Images Live
TITLE=hang.png #Icon Name

#----------------------------------------------------

# <summary>
#  * Following Portion defines:
#  * Styles for window elements
#  * Where To Apply Which Style
#  * And Writes all this to gtkrc_mono file from where the actual window reads styles on runtime
#  * GTK2_RC_FILES is an environmental variable idk thats just how GTKdialog works
# </summary>

def_styles(){
    echo '
    style "windowStyle" {
        bg_pixmap[NORMAL] = "back.jpg"
        fg[NORMAL] = "#696969"
        font_name="Poppins 34"
    }
    widget_class "<GtkWindow>*" style "windowStyle"
    ' > ${GTKRC_LOCATION}/gtkrc_mono
    export GTK2_RC_FILES=${GTKRC_LOCATION}/gtkrc_mono
}

#----------------------------------------------------

# <summary>
#  * Utility Function
#  * Loops From A to Z To Print Buttons On Screen
#  * Called In Game Window
# </summary>

buttonprint(){
    for x in {a..z}
    do
        echo '<button width-request="70">
            <label>'$x'</label>
            <action>echo '$x' > userinput</action>
            <action>Exit:Quitted_Successfully</action>
        </button>'
        case $x in
          "m")
        echo "</hbox><hbox>"
        ;;
        esac
    done
}
# ----------------------------------------------------
# Below Are The Format For Our 4 Pages StartScreen, DifficultyPage, Actual Game Window And The Hanged Prompt 



# <summary>
#  * Design For Start Page
#  * Shows Main Window In The End
# </summary>
startscreen(){
export MAIN_DIALOG=' 
<window 
    title="HANGMAN"
    default-width="900"
    default-height="600"
    border-width="100"
    name="MyWindow">
    <vbox>
        <pixmap>
            <input file>hang.png</input>
            <height>300</height>
        	<width>300</width>
        </pixmap>
        <text name="MyText" use-markup="true">
            <label>"<b>HANGMAN</b>"</label>
        </text>
        <hbox>
            <button width-request="200">
                <label>Play</label>
                <action>gtkdialog --program difficulty</action>
                <action>Exit:Quitted_Successfully</action>
            </button>
            <button width-request="350">
                <label>Leaderboard</label>
                <action>gtkdialog --program leaderboard</action>
            </button>
            <button width-request="200">
                <label>Quit</label>
                <action>echo 5 > temp_difficulty</action>
                <action>Exit:Quitted_Successfully</action>
            </button>
        </hbox>
        <text name="MyText" use-markup="true">
            <label>"Created By Eqan And Basit"</label>
        </text>
    </vbox>
</window>
'
gtkdialog --program MAIN_DIALOG
}

# ----------------------------------------------------

# <summary>
#  * Design For Game Page
#  * Draws Game Window In The End
# </summary>
game(){
export game=' 
<window 
    title="HANGMAN"
    default-width="900"
    default-height="600"
    border-width="100"
    name="MyWindow">
    <vbox>
        <pixmap>
            <input file>hang.png</input>
            <height>150</height>
        	<width>150</width>
        </pixmap>
        <text name="MyText" use-markup="true">
            <label>"<b>Chances Left : '"`sed -n "2p" TempData`"' | Current Round : '"`sed -n "3p" TempData`"'</b>"</label>
        </text>
        <text name="MyText" use-markup="true">
            <label>"<b>Score : '"`sed -n "4p" TempData`"' | Mode : '"`sed -n "5p" TempData`"'</b>"</label>
        </text>
        <vbox>
        <text>
            <label>'"`sed -n "6p" TempData`"'</label>
        </text>
    </vbox>
    <hbox>
        '"`buttonprint`"'
    </hbox>
        <button width-request="50">
            <label>Quit</label>
            <action>echo 5 > temp_difficulty</action>
            <action>Exit:Quitted_Successfully</action>
        </button>
    </vbox>
</window>
'
gtkdialog --program game
}

# ----------------------------------------------------


# <summary>
#  * Design For Diffculty Selection Page
# </summary>
difficulty(){
export difficulty=' 
<window 
    title="HANGMAN"
    default-width="900"
    default-height="600"
    border-width="100"
    name="MyWindow">
<vbox>
        <pixmap>
            <input file>hang.png</input>
            <height>90</height>
        	<width>90</width>
        </pixmap>
        <text name="MyText" use-markup="true">
            <label>"<b>SELECT DIFFICULTY</b>"</label>
        </text>
        <vbox>
            <button width-request="70">
                <label>'Easy'</label>
                <action>echo 1 > temp_difficulty</action>
                <action>Exit:Quitted_Successfully</action>
                </button>
            <button width-request="70">
                <label>'Medium'</label>
                <action>echo 2 > temp_difficulty</action>
                <action>Exit:Quitted_Successfully</action>
                </button>
            <button width-request="70">
                <label>'Hard'</label>
                <action>echo 3 > temp_difficulty</action>
                <action>Exit:Quitted_Successfully</action>
                </button>
            <button width-request="70">
                <label>'Custom'</label>
                <action>echo 4 > temp_difficulty</action>
                <action>Exit:Quitted_Successfully</action>
                </button>
        </vbox>
</vbox>
</window>
'
}

# ----------------------------------------------------

# <summary>
#  *Mini Prompt
# </summary>
prompt(){
export prompt=' 
<window 
    title="HANGMAN"
    default-width="200"
    default-height="200"
    border-width="50"
    name="MyWindow">
<vbox>
<hbox>'
if [[ "$1" == "OOPS, You Are Hanged" ]]
then
    prompt=${prompt}'
        <pixmap>
            <input file>hanged.png</input>
            <height>120</height>
        	<width>120</width>
        </pixmap>'
    fi
prompt=${prompt}'        
        <text name="MyText" use-markup="true">
            <label>"<b> '$1'</b>"</label>
        </text>
        </hbox>
        <vbox>
            <button width-request="250">
                <label>'Continue'</label>
                <action>Exit:Quitted_Successfully</action>
            </button>
        </vbox>
</vbox>
</window>
'
gtkdialog --program prompt
}

# ----------------------------------------------------

# <summary>
#  * Leaderboard Layout
# </summary>
leaderboard(){
export leaderboard=' 
<window 
    title="HANGMAN"
    default-width="900"
    default-height="600"
    border-width="100"
    name="MyWindow">
<vbox>
        <pixmap>
            <input file>hang.png</input>
            <height>120</height>
        	<width>120</width>
        </pixmap>       
        <frame Leaderboard>
        <vbox>
        <text name="MyText" use-markup="true">
            <label>"<b>'"`cat HighScores.txt`"'</b>"</label>
        </text>
        </vbox>
        </frame>
        <vbox>
            <button width-request="250">
                <label>'Back'</label>
                <action>Exit:Quitted_Successfully</action>
            </button>
        </vbox>
</vbox>
</window>
'
}
#-----------------------------------------------------
main(){
    leaderboard
    def_styles
    difficulty
    startscreen
    game_mode_menu
}


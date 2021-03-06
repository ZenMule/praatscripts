#    <Draw_formants_plot_Std_Dev.praat>
#    (Documentation at http://github.com/lingdoc/praatscripts)
#    
#    Extracts duration and F0 across a duration defined by the TextGrid for a wav file.
#    Writes results to a tab-delimited CSV file with the same name as the wav file.
#    Allows the user to plot pitch traces in the Praat picture window.
#
#    Copyright (C) 2014 Hiram Ring, José Joaquín Atria
#    <hiram1 AT ntu DOT edu DOT sg>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    A copy of the GNU General Public License can be found at <http://www.gnu.org/licenses/>.
#
#    Incorporating part of: DRAW_FORMANT_PLOT_FROM_TABLE.PRAAT by KRISTINE YU
#    and tutorial by Bartlomiej Plichta: <http://www.youtube.com/watch?v=IfLqPJM4SQU>
#    Updated March 2017 to work well with 'dur_f0_F1_F2_F3_intensity.praat' and to
#    allow for sequential plotting of single characters.
#    
#    Purpose: Draw formant plot from table with ellipse showing standard deviation
#    and IPA character at the center of the ellipse
#    Takes formant data from a CSV where there are three columns, two of which are
#    labeled 'F1' and 'F2', and one of which is labeled with the corresponding
#    IPA character. Any label can be used for the IPA character column, and this is
#    specified in the form.

form Draw formant plot from text file of formant values...
   comment Tabbed/CSV file to read from
   sentence Data_file output.csv
   comment Name of column with vowel characters
   word Vowel_column Label
   comment Do you want to plot a single character?
   word Plot_only 
   # If you want to plot a single vowel character
   boolean Sequential 0
   # If you want to plot characters sequentially
   comment Plot settings:
   positive Font_size 20
   positive F1_min 200
   positive F1_max 1000
   positive F2_min 500
   positive F2_max 2700
   # positive F3_min 800
   # positive F3_max 5000
   positive Standard_deviation_(for_ellipses) 2
   boolean Garnish 1 ; Plot decorations
endform

# Decorate plot
if garnish = 1
   call garnish
endif

call checkFilename "'data_file$'" Open formant data
formant_file$ = checkFilename.name$

# Open formant text file
raw_table = Read Table from comma-separated file... 'formant_file$'

call plot

removeObject: selected("Table")
exitScript ()

procedure reset
   beginPause: "Choose the next vowel to plot"
      word: "Vowel", ""
   clicked = endPause: "Stop", "Continue", 2, 1
   if clicked = 1    
      # react to cancel
      exitScript ()
   elsif clicked = 2
      plot_only$ = vowel$
      call plot
      sequential = 1
   endif
endproc

procedure plot

   raw_table = selected("Table")
   Sort rows... 'vowel_column$'

   vowel_types = Collapse rows... 'vowel_column$' "" "" "" ""  
   total_vowels = Get number of rows

   if plot_only$ != ""
      test = nocheck Extract rows where column (text)... 'vowel_column$' "is equal to" 'plot_only$'
      not_empty = Get number of rows
      if not_empty
         select vowel_types
         Remove
         vowel_types = test
      else
         exit No data for vowel selected for exclusive plotting: 'plot_only$'.'newline$'
      endif
      total_vowels = 1
   endif
   
   
   select raw_table
   
   for i to total_vowels
      select vowel_types
      vowel$ = Get value... i 'vowel_column$'
      
      select raw_table

      vowel_data = Extract rows where column (text)... 'vowel_column$' "is equal to" 'vowel$'
      f1 = Get mean... F1
      f2 = Get mean... F2
      Text special... f2 Centre f1 Half Times font_size 0 'vowel$'
      Draw ellipse (standard deviation)... F2 f2_max f2_min F1 f1_max f1_min standard_deviation no
      Remove
   endfor
   
   select vowel_types
   Remove
   
   select raw_table

   if sequential = 1
      call reset
   endif
endproc

procedure garnish
   call viewport
   Viewport... viewport.left viewport.right viewport.top viewport.bottom

   Line width... 1
   Font size... 16
   Times
   Black
   Plain line
   Axes... f2_max f2_min f1_max f1_min
   Draw inner box
   Marks bottom... 5 yes yes yes
   Marks left... 5 yes yes yes
   Text left... yes %F_1 (Hz)
   Text bottom... yes %F_2 (Hz)
endproc

procedure viewport
   .info$  = Picture info
   .left   = extractNumber(.info$, "Outer viewport left: ")
   .right  = extractNumber(.info$, "Outer viewport right: ")
   .top    = extractNumber(.info$, "Outer viewport top: ")
   .bottom = extractNumber(.info$, "Outer viewport bottom: ")
endproc

# From https://github.com/jjatria/plugin_jjatools
procedure checkFilename .name$ .label$
   if .name$ = ""
      .name$ = chooseReadFile$(.label$)
   endif
   if .name$ = ""
      exit
   endif
endproc
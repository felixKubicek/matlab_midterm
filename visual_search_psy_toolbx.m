clear all;

addpath('lib/getResponse');

global DEADLINE = 15;

global WHITE = [255 255 255];
global RED = [202 19 19];
global GREEN = [102 204 0];
global BLACK = [0 0 0];

global FEATURE = 'F';
global CONJUNCTION = 'C';
global SEARCH_TYPES = [FEATURE, CONJUNCTION];
global SET_SIZES = [1, 5, 15, 31];
global TRAILS_PER_SEARCH = 1;

global FS = 36;


function main()
  global FEATURE;
  global CONJUNCTION;
  global TRAILS_PER_SEARCH;
  global SEARCH_TYPES;
  global SET_SIZES; 
  global RED;
  global GREEN;
  global FS;

  red_x = struct('chr', 'x', 'color', RED);
  red_o = struct('chr', 'o', 'color', RED);
  green_x = struct('chr', 'x', 'color', GREEN);
  green_o = struct('chr', 'o', 'color', GREEN);

  distractors.(FEATURE) = [green_x, green_o];
  targets.(FEATURE) = [red_x, red_o];

  distractors.(CONJUNCTION) = [green_x, red_o];
  targets.(CONJUNCTION) = [red_x, green_o];

  search_results = [];
  for searchTypeIdx = 1:length(SEARCH_TYPES)
    for setSizeIdx = 1:length(SET_SIZES)
      for targetPresent = 0:1
        search_results = [search_results struct('search_type', SEARCH_TYPES(searchTypeIdx),
                                                'set_size', SET_SIZES(setSizeIdx),
                                                'target_present', logical(targetPresent),
                                                'results', [])];
      end
    end
  end

  try
    [w,srect] = init_display();

    wrong_answers = 0;
    timeouts = 0;
    
    while true
  
      remaining_searches = (search_results(cellfun(@length, {search_results.results}) < TRAILS_PER_SEARCH));

      if ~isempty(remaining_searches)

        % pick random search (defined by search type and set size and target present)
        current_search = remaining_searches(1 + round(rand(1)*(length(remaining_searches)-1)));

        display_prolog(w, current_search.search_type, targets);
        [timeout, correct, reaction_time] = display_search(w, srect, current_search.set_size, 
                                                           current_search.target_present, 
                                                           current_search.search_type, distractors, targets);
        if ~timeout
          if correct
            % save reaction time as result in corresponding search
            result_index = find(arrayfun(@(s) isequal(s, current_search), search_results));
            search_results(result_index).results(end + 1) = reaction_time;
            % search_results(result_index)
          else
            wrong_answers++;
          end
        else
          timeouts++;
        end
  
      else
        break;
      end
    end

    sca;

  catch
    sca;
    rethrow(lasterror); 
  end
 
  generate_results(search_results, wrong_answers);

end


function [w, srect] = init_display()
  global WHITE;

  Screen('Preference', 'SkipSyncTests', 1);
  Screen('Preference','SuppressAllWarnings', 1);

  desiredRefreshRate = 60;
  desiredPixelSize = 32;

  rect = [0 0 640 480]; 

  screenNumber=max(Screen('Screens'));

  res = NearestResolution(screenNumber, rect(3), rect(4), desiredRefreshRate, desiredPixelSize);
  if res.hz == 0
    res.hz = 60;
  end
  [w, srect] = Screen('OpenWindow', screenNumber, WHITE, [0 0 res.width res.height], res.pixelSize);

end


function display_prolog(win, searchType, targets)
  global FS;
  global BLACK;

  help_text = sprintf(strcat('Press any button to continue to search.\n',
                             'Then press "j" for target present.\n',
                             'Or press "k" for targent not present.'));

  Screen('TextSize',win, 20);
  DrawFormattedText(win, help_text, 0,20, BLACK);
  DrawFormattedText(win, 'Targets:', 0, 100, BLACK);

  Screen('TextSize',win, FS);
  for i = 1:length(targets.(searchType))
    DrawFormattedText(win, targets.(searchType)(i).chr, i*20, 120, targets.(searchType)(i).color);
  end

  Screen('Flip', win);

  % wait for all keys released, then wait for single keystroke
  KbStrokeWait();

end


function [timeout, correct, reaction_time] = display_search(win, srect, setSize, targetPresent, searchType, distractors, targets)
  global FS;
  global DEADLINE;

  Screen('TextSize',win, FS);

  half = (setSize -1)/2;

  x = rand(setSize , 1) * (srect(RectRight) - FS);
  y = rand(setSize , 1) * (srect(RectBottom) - FS); 

  for distractor_id = 1:(setSize-1)
    if distractor_id <= half
      DrawFormattedText(win, distractors.(searchType)(1).chr, x(distractor_id), y(distractor_id), 
                        distractors.(searchType)(1).color);
    else
      DrawFormattedText(win, distractors.(searchType)(2).chr, x(distractor_id), y(distractor_id), 
                        distractors.(searchType)(2).color);
    end                    
  end

  if targetPresent 
    whichTarget = round(rand()) + 1;
    DrawFormattedText(win, targets.(searchType)(whichTarget).chr, x(setSize), y(setSize),
                      targets.(searchType)(whichTarget).color);
  else
    whichDistractor = round(rand()) + 1;
    DrawFormattedText(win, distractors.(searchType)(whichDistractor).chr, x(setSize), y(setSize),  
                      distractors.(searchType)(whichDistractor).color);
  end
   
  responseSetCodes = KbName({'j', 'k'});
  
  t0 = Screen('Flip', win);
  [reaction_time, response] = getResponse(responseSetCodes, t0, DEADLINE);

  timeout = strcmp(response,'DEADLINE');
  correct = ((response == 'j' && targetPresent) || (response == 'k' && ~targetPresent));
end


function generate_results(search_results, wrong_answers)
  global FS;
  global SET_SIZES;
  global FEATURE;
  global CONJUNCTION;

  results_fig = figure; % in octave figure has to be visible ('Visible', 'off');
  
  filter_results = @(search_results, search_type, target_present) search_results(
                        find(arrayfun(@(s) s.search_type == search_type && s.target_present == target_present, search_results)));

  get_results = @(search_results, search_type, target_present) cellfun(@mean, 
                  {filter_results(search_results, search_type, target_present).results});

  feature_present_avg_times = get_results(search_results, FEATURE, true);
  feature_absent_avg_times = get_results(search_results, FEATURE, false);

  ax1 = subplot(2,1,1);

  plot(ax1, SET_SIZES, feature_present_avg_times, SET_SIZES, feature_absent_avg_times);
  legend(ax1, 'feature, present', 'feature, absent', 'Location','northwest');

  conjunction_present_avg_times = get_results(search_results, CONJUNCTION, true);
  conjunction_absent_avg_times = get_results(search_results, CONJUNCTION, false);

  ax2 = subplot(2,1,2);

  plot(ax2,  SET_SIZES, conjunction_present_avg_times, SET_SIZES, conjunction_absent_avg_times);
  legend(ax2, 'conjunction, present', 'conjunction, absent', 'Location','northwest');

  axis(ax1, [0 32 0 15]);
  axis(ax2, [0 32 0 15]);

  results_heading = sprintf('Search Results. Number of wrong answers: %d.', wrong_answers);
  title(ax1, results_heading, 'FontSize', 20);

  print(results_fig,'results','-dpdf');

end

% program entry point
main()

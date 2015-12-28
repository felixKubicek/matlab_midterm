clear all;

global RED = [202 19 19]/255;
global GREEN = [102 204 0]/255;

global FEATURE = 'F';
global CONJUNCTION = 'C';
global SEARCH_TYPES = [FEATURE, CONJUNCTION]
global SET_SIZES = [1, 5, 15, 31];
global TRAILS_PER_SEARCH = 2;


global FS = 36;



function main()
  global FEATURE;
  global CONJUNCTION;
  global TRAILS_PER_SEARCH;
  global SEARCH_TYPES;
  global SET_SIZES; 
  global RED;
  global GREEN;

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
      search_results = [search_results struct('search_type', SEARCH_TYPES(searchTypeIdx),
                                              'set_size', SET_SIZES(setSizeIdx),
                                              'results', [])];
    end
  end

  % init_display();

  searches = search_results(cellfun(@length, {search_results.results}) < TRAILS_PER_SEARCH);

  % pick random search (defined by search type and set size and target present)
  search = searches(1 + round(rand(1)*(length(searches)-1)));





  
  % display_prolog(CONJUNCTION, targets);
  % [correct, reaction_time] = display_search(15, 1, CONJUNCTION, distractors, targets)

end


function init_display()
  global FS;

  siz = get(0, 'ScreenSize'); 
  fig = figure('Position', siz);
  axis ([ -0.1 1.1 -0.1 1.1])
  set(gca, 'FontName', 'Consolas', 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 
      'YTick', [], 'Box', 'off', 'XColor', [1 1 1], 'YColor', [1 1 1], 'FontSize', FS);
end


function display_prolog(searchType, targets)
  global FS;

  help_text = sprintf(strcat('Press any button to continue to search.\n',
                             'Then press "j" for target present.\n',
                             'Or press "k" for targent not present.'));

  text(0, 0.75, help_text, 'FontSize', 20);

  text(0, 0.56, 'Targets:', 'FontSize', 20);
  for i = 1:length(targets.(searchType))
    text((i-1)*0.03, 0.5, targets.(searchType)(i).chr, 'Color',
         targets.(searchType)(i).color, 'FontSize', FS);
  end

  FlushEvents('keyDown');
  GetChar();
  
  cla;
end


function [correct, reaction_time] = display_search(setSize, targetPresent, searchType, distractors, targets)
  global FS;

  half = (setSize -1)/2;
  distractorIdentity = [zeros(half, 1); ones(half, 1)] + 1;

  x = rand(setSize , 1);
  y = rand(setSize , 1);

  ng1 = text(x(distractorIdentity==1), y(distractorIdentity==1), 
             distractors.(searchType)(1).chr, 'Color', distractors.(searchType)(1).color, 'FontSize', FS);

  ng2 = text(x(distractorIdentity==2), y(distractorIdentity==2), 
             distractors.(searchType)(2).chr, 'Color', distractors.(searchType)(2).color, 'FontSize', FS);
  
  if targetPresent 
    whichTarget = round(rand()) + 1;
    g = text(x(setSize), y(setSize), targets.(searchType)(whichTarget).chr, 'Color',
             targets.(searchType)(whichTarget).color, 'FontSize', FS);
  else
    whichDistractor = round(rand()) + 1;
    g = text(x(setSize), y(setSize), distractors.(searchType)(whichDistractor).chr, 
             'Color', distractors.(searchType)(whichDistractor).color, 'FontSize', FS);
  end

  FlushEvents('keyDown');

  tic
  pressed_key = GetChar();
  reaction_time = toc;
  correct = ((pressed_key == 'j' && targetPresent) || (pressed_key == 'k' && ~targetPresent));

end
 

% program entry point
main()

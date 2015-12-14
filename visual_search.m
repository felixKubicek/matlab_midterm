clear all;

global RED = [202 19 19]/255;
global GREEN = [102 204 0]/255;

global FEATURE = 'F';
global CONJUNCTION = 'C';

global FS = 36;
global SET_SIZES = [1, 5, 15, 31];


function main()
  global FEATURE;
  global CONJUNCTION;
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

  setup_display();
  feature_search(15, 1, CONJUNCTION, distractors, targets)
end

function setup_display()
  global FS;
  siz = get(0, 'ScreenSize'); 
  fig = figure('Position', siz);
  cla;
  axis ([ -0.1 1.1 -0.1 1.1])
  set(gca, 'FontName', 'Consolas', 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 
      'YTick', [], 'Box', 'off', 'XColor', [1 1 1], 'YColor', [1 1 1], 'FontSize', FS);
end

function feature_search(setSize, targetPresent, searchType, distractors, targets)
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

end

% program entry point
main()
fnames = {'key', 'name', 'machine', 'gain', 'offset'};
content = {'foo', 'asdf', 'big_red', 23, 0.3; ...
           'bar', 'jklm', 'eagle', 19, -0.1; ....
          }
      
as_struct = cell2struct(content(:,2:end), fnames(2:end), 2);
as_struct_in_cells = arrayfun(@(x) x, as_struct', 'UniformOutput', false);
mymap = containers.Map(content(:,1), as_struct_in_cells);
mymap('foo').machine  % ans = big_red

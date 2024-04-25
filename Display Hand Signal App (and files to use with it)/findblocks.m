function [block_ind, block_length] = findblocks(indexvals)

index = (1:length(indexvals))';

block_start = find(diff(indexvals) == 1)+1;
block_end = find(diff(indexvals) == -1);

if ~isempty(block_end) && ~isempty(block_start)
    if block_end(1) < block_start(1)
        block_start = [1; block_start];
    else
    end
    if block_start(end) > block_end(end)
        block_end = [block_end; index(end)];
    else
    end
    block_ind = [block_start, block_end];
    block_length = block_end - block_start;
elseif ~isempty(block_start) && isempty(block_end) && length(block_start) == 1
    block_ind = [block_start, index(end)];
    block_length = index(end) - block_start;
elseif isempty(block_start) && ~isempty(block_end) && length(block_end) == 1
    block_ind = [1, block_end];
    block_length = block_end - 1;    
else
    block_ind = [];
    block_length = [];
end

end

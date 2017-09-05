require 'concurrent/thread_safe/util/adder'

module Metrics
  module Core
    class Adder < Concurrent::ThreadSafe::Util::Adder
      
        # Returns the current sum.  The returned value is _NOT_ an
        # atomic snapshot: Invocation in the absence of concurrent
        # updates returns an accurate result, but concurrent updates that
        # occur while the sum is being calculated might not be
        # incorporated.
        def sum_then_reset
          x = base
          self.base = 0
          if current_cells = cells
            current_cells.each do |cell|
              if cell
                x += cell.value
                cell.value = 0
              end
            end
          end
          x
        end
    end
  end
end

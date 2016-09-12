module Versed
  class Task
    attr_accessor :category_id, :time_spent, :time_scheduled

    def initialize(category_id)
      @category_id = category_id
    end

    def to_hash
      {
        "time_spent" => self.time_spent.to_s,
        "time_scheduled" => self.time_scheduled.to_s,
        "style" => style
      }
    end

    private

    DANGER_STYLE = "danger"
    WARN_STYLE = "warning"
    SUCCESS_STYLE = "success"

    def style
      return unless self.time_scheduled && self.time_scheduled > 0

      if !self.time_spent || self.time_spent <= 0
        return DANGER_STYLE
      elsif self.time_spent < self.time_scheduled
        return WARN_STYLE
      else
        return SUCCESS_STYLE
      end
    end
  end
end

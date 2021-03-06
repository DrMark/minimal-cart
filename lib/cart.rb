#t See LICENSE file in the root for details
class Cart
  attr_reader :orders
  attr_reader :weight
  attr_reader :price 
  alias :total :price

  def initialize
    @orders = Hash.new
    @price  = 0.0
    @weight = 0.0
  end

  def clear
    initialize
  end

  def add(orderable_id)
    if @orders.key? orderable_id
      @orders[orderable_id].quantity += 1
    else 
      @orders[orderable_id] = Order.create_from orderable_id
    end
    @price += @orders[orderable_id].orderable.price
    @weight += @orders[orderable_id].orderable.weight
    @orders[orderable_id]
  end

  def update(orderable_id, quantity)
    if quantity.to_i == 0
      remove(orderable_id)
    else
      update_totals :subtract, orderable_id
      begin 
        @orders[orderable_id].quantity = quantity.to_i
      rescue IndexError
        raise 'No order found on Cart.update'
      end
      update_totals :add, orderable_id 
    end
  end

  def remove(orderable_id)
    update_totals :subtract, orderable_id
    begin
      @orders.delete orderable_id
    rescue IndexError
      raise 'No order found on Cart.remove'
    end
  end

  private
  def update_totals(update, id)
    if update == :add
      @price += @orders[id].calc_price
      @weight += @orders[id].calc_weight
    elsif update == :subtract
      @price -= @orders[id].calc_price
      @weight -= @orders[id].calc_weight
    else
      raise 'No valid update type passed to Cart.update_totals'
    end
  end

end

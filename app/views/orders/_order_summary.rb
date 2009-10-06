%table
  %thead
    %tr
      %th Qty
      %th Description
      %th Notes
      %th Cost($)

  %tbody#order_items
    -@order.order_items.each do |item|
      %tr
        %td=h item.quantity
        %td=h item.description
        %td=h item.notes
        %td=h item.cost

  %tfoot
    %tr
      %td(colspan="3") Total
      %td=h @order.total
 
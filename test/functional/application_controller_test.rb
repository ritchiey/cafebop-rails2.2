require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  
  context "With a current_subdomain" do
    setup do
      controller.stubs(:current_subdomain).returns('xxx')
    end
    
    context "and a shop" do
      setup do
        @shop = mock
      end

      context "calling fetch_shop" do
        setup do
          Shop.expects(:find_by_id_or_permalink).returns(@shop)
          controller.send(:fetch_shop)
        end
        # should_assign_to(:shop)
        should "be ok" do
          
        end
      end
      
      should "include operating_times with shop by default" do
        assert_same_elements [], controller.send(:include_with_shop)
      end
      
      context "include_menus_with_shop" do
        setup do
          controller.send(:include_menus_with_shop)
        end
        should "add menus to include_with_shop" do
          assert_same_elements [{:menus=>{:menu_items=>[:sizes,:flavours]}}], controller.send(:include_with_shop)
        end
        
        context "and include_operating_times_with_shop" do
          setup do
            controller.send(:include_operating_times_with_shop)
          end

          should "include the operating times as well" do
            assert_same_elements [:operating_times, {:menus=>{:menu_items=>[:sizes,:flavours]}}], controller.send(:include_with_shop)
          end
        end
        
      end
      
      # context "and an order" do
      #   setup do
      #     @order = mock
      #   end
      # 
      #   context "calling fetch_order" do
      #     setup do
      #       Order.expects(:find).returns(@order)
      #       controller.send(:fetch_order)
      #     end
      #     should_assign_to(:order) {@order}
      #     should_assign_to(:shop) {@order.shop}
      #   end
      # 
      # 
      # end
      



    end


  
  end
  
end
  
  

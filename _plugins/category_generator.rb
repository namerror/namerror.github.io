# Generates a page for each post category in the site
module Jekyll
    class CategoryPageGenerator < Generator
        safe true

        def generate(site)
            categories = site.data['post_categories']
            generate_category_pages(site, categories)
        end

        private

        def generate_category_pages(site, categories, parent=nil)
            categories.each do |category|
                site.pages << CategoryPage.new(site, category, parent)
                if category['subcategories']
                    generate_category_pages(site, category['subcategories'], category)
                end
            end
        end
    end

    class CategoryPage < Page
        def initialize(site, category, parent)
            @site = site
            @base = site.source
            @dir = category['url'].gsub(/^\//, '')
            @name = 'index.html'

            self.process(@name)
            self.read_yaml(File.join(@base, '_layouts'), 'post_category.html')
            self.data['category'] = category
            self.data['parent'] = parent
            self.data['title'] = category['category'].capitalize
            self.data['subcategories'] = category['subcategories'] || []
        end
    end
end
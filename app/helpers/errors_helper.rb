module ErrorsHelper

    def there_is_an_error?
        !params[:errors].nil?
    end

end

class SubjectTermsController < ApplicationController
  make_resourceful do
    actions :index, :show
    publish :xml, :json, :attributes => [:id, :name]
  end
end

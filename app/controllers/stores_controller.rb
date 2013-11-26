class StoresController < ApplicationController
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  require 'hpricot'
  require 'open-uri'

  # GET /stores
  # GET /stores.json
  def index
    @stores = Store.all
    respond_to do |format|
      format.html {}
      format.json { @stores }
    end
  end

  # GET /stores/scraping
  def scraping
    baseUrl = 'http://www.starbucks.co.jp'
    url = baseUrl + '/store/search/result_store.php?pref_code=13'
    puts '---'
    listPage = Hpricot( open( url ).read )
    (listPage/'tr').each { |tr|
      #((tr/'td.storeName')/'a:nth(0)').each {
      #}
      #puts a.attributes['href']
        #detailPage = Hpricot( open(baseUrl + a['href']).read )
        #puts (detailPage/'h1').first.inner_text
    }
    puts '---'
    render:json => ''
  end
  # GET /stores/1
  # GET /stores/1.json
  def show
  end

  # GET /stores/new
  def new
    @store = Store.new
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(store_params)

    respond_to do |format|
      if @store.save
        format.html { redirect_to @store, notice: 'Store was successfully created.' }
        format.json { render action: 'show', status: :created, location: @store }
      else
        format.html { render action: 'new' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to @store, notice: 'Store was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store.destroy
    respond_to do |format|
      format.html { redirect_to stores_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def store_params
      params.require(:store).permit(:name, :address, :lng, :lat)
    end
end

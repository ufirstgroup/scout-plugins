require File.expand_path('../../test_helper.rb', __FILE__)
require File.expand_path('../elasticsearch_index_status.rb', __FILE__)

class ElasticsearchIndexStatusTest < Test::Unit::TestCase
  def setup
    @options = parse_defaults("elasticsearch_index_status")
    @options['index_name'] = 'test_index'
    @plugin = ElasticsearchIndexStatus.new(nil, {}, @options)
  end
  
  def teardown
    FakeWeb.clean_registry
  end

  def test_processes_indices_in_old_format
    response = {
      '_all' => {
        'indices' => {
          'test_index' => {
            'primaries' => {
              'store' => { 'size_in_bytes' => 3145728 },
              'docs' => { 'count' => 5 }
            },
            'total' => { 'store' => { 'size_in_bytes' => 4194304 } },
          }
        }
      }
    }.to_json
    FakeWeb.register_uri(:get, "http://127.0.0.1:9200/test_index/_stats", :body => response)
    res = @plugin.run
    assert_equal [{ :primary_size => 3.0 }, { :size => 4.0 }, { :num_docs => 5 }], res[:reports]
  end

  def test_processes_indices_in_new_format
    response = {
      "indices" => {
        "test_index" => {
          "primaries" => {
            "docs" => { "count" => 8 },
            "store" => { "size_in_bytes" => 6291456 }
          },
          "total" => { "store" => { "size_in_bytes" => 7340032 } }
        }
      }
    }.to_json
    FakeWeb.register_uri(:get, "http://127.0.0.1:9200/test_index/_stats", :body => response)
    res = @plugin.run
    assert_equal [{ :primary_size => 6.0 }, { :size => 7.0 }, { :num_docs => 8 }], res[:reports]
  end
end

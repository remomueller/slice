# frozen_string_literal: true

require 'test_helper'

# Tests to assure variables on a project can be validated.
class ValidateControllerTest < ActionController::TestCase
  test 'should validate variable' do
    post :variable, params: {
      project_id: projects(:one), variable_id: variables(:date),
      value: { month: '1', day: '1', year: '2000' }
    }, xhr: true, format: 'json'

    json = JSON.parse(response.body)
    assert_equal 'in_soft_range', json['status']
    assert_equal 'January 1, 2000', json['formatted_value']
    assert_equal '', json['message']
    assert_response :success
  end

  test 'should validate variable with blank fields' do
    post :variable, params: {
      project_id: projects(:one), variable_id: variables(:date),
      value: { month: '', day: '', year: '' }
    }, xhr: true, format: 'json'

    json = JSON.parse(response.body)
    assert_equal 'blank', json['status']
    assert_nil json['formatted_value']
    assert_equal '', json['message']
    assert_response :success
  end

  test 'should validate return out of range for variable' do
    post :variable, params: {
      project_id: projects(:one), variable_id: variables(:date),
      value: { month: '12', day: '31', year: '1989' }
    }, xhr: true, format: 'json'

    json = JSON.parse(response.body)
    assert_equal 'out_of_range', json['status']
    assert_equal 'December 31, 1989', json['formatted_value']
    assert_equal 'Date Outside of Range', json['message']
    assert_response :success
  end

  test 'should validate return invalid for variable' do
    post :variable, params: {
      project_id: projects(:one), variable_id: variables(:date),
      value: { month: '2', day: '31', year: '2000' }
    }, xhr: true, format: 'json'

    json = JSON.parse(response.body)
    assert_equal 'invalid', json['status']
    assert_nil json['formatted_value']
    assert_equal 'Not a Valid Date', json['message']
    assert_response :success
  end

  test 'should validate return inside hard range for variable' do
    post :variable, params: {
      project_id: projects(:one), variable_id: variables(:date),
      value: { month: '6', day: '15', year: '1995' }
    }, xhr: true, format: 'json'

    json = JSON.parse(response.body)
    assert_equal 'in_hard_range', json['status']
    assert_equal 'June 15, 1995', json['formatted_value']
    assert_equal 'Date Outside of Soft Range', json['message']
    assert_response :success
  end
end

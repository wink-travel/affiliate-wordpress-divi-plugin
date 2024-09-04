<?php

class IKTDItineraryform extends ET_Builder_Module {
	protected $namespace = 'iko-travel';
	public $slug       = 'iktd_itineraryform';
	public $vb_support = 'on';

	protected $module_credits = array(
		'module_uri' => 'https://wink.travel/',
		'author'     => 'Wink',
		'author_uri' => 'https://wink.travel/',
	);

	public function init() {
		$this->name = esc_html__( 'iko Itinerary Form', $this->namespace );
		$this->settings_modal_toggles  = array(
			'iko' => array(
				'toggles' => array(
					'ikoOptions'   => esc_html( 'iko Settings', $this->namespace )
				),
			),
		);
	}

	public function get_fields() {
		return array(
			'content' => array(
				'label'           => __( "This component does not require any configuration.", $this->namespace ),
				'type'            => 'iktd_input',
				'option_category' => 'basic_option',
				'description'     => __( "Simply ensure that you have entered the correct Client-ID and Client-Secret in the iko plugin settings.", $this->namespace ),
				'toggle_slug'     => 'ikoOptions',
			),
		);
	}

	public function render( $attrs, $content = null, $render_slug ) {
		return do_shortcode('[ikoitineraryform]');
	}
}

new IKTDItineraryform;

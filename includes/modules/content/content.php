<?php

class IKTDContent extends ET_Builder_Module {
	protected $namespace = 'iko-travel';
	public $slug       = 'iktd_content';
	public $vb_support = 'on';

	protected $module_credits = array(
		'module_uri' => 'https://wink.travel/',
		'author'     => 'Wink',
		'author_uri' => 'https://wink.travel/',
	);

	public function init() {
		$this->name = esc_html__( 'iko Content', $this->namespace );
		$this->settings_modal_toggles  = array(
			'iko' => array(
				'toggles' => array(
					'ikoOptions'   => esc_html( 'iko Settings', $this->namespace )
				),
			),
		);
	}

	public function get_fields() {
		$shortcodes = apply_filters( 'ikoShortcodes', $shortcodes);
		$options = array();
		if (!empty($shortcodes['ikocontent'])) {
			foreach($shortcodes['ikocontent']['params'][0]['value'] as $optionKey => $optionValue) {
				$options[$optionValue] = $optionKey;
			}
		}
		$all_types_tab_slug    = 'iko Options';
		return array(
			'layoutid' => array(
				'label'           => __( "Layouts", $this->namespace ),
				'type'            => 'select',
				'option_category' => 'basic_option',
				'description'     => __( "Select any of your saved layouts. We strongly recommend to use this block only in full-width content areas and not in columns.", $this->namespace ),
				'toggle_slug'     => 'ikoOptions',
				'options'	=> $options,
			),
		);
	}

	public function render( $attrs, $content = null, $render_slug ) {
		$settings = $this->get_settings_for_display();		
		return do_shortcode('[ikocontent layoutid="'.$this->props['layoutid'].'"]');
	}
}

new IKTDContent;

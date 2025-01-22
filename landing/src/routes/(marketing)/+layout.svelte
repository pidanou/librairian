<script lang="ts">
  import { WebsiteName } from "./../../config"
  import "../../app.css"

  interface Props {
    children?: import("svelte").Snippet
  }

  let { children }: Props = $props()
</script>

<div class="navbar bg-base-100 container mx-auto">
  <div class="flex-1">
    <a class="btn btn-ghost normal-case text-xl" href="/">{WebsiteName}</a>
  </div>
  <div class="flex-none">
    <ul class="menu menu-horizontal px-1 hidden sm:flex font-bold text-lg">
      <li class="md:mx-4">
        <a
          href="https://app.librairian.io"
          class="btn btn-sm btn-primary border border-primary"
        >
          Open app
        </a>
      </li>
    </ul>
    <div class="dropdown dropdown-end sm:hidden">
      <!-- svelte-ignore a11y_label_has_associated_control -->
      <!-- svelte-ignore a11y_no_noninteractive_tabindex -->
      <label tabindex="0" class="btn btn-ghost btn-circle">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-5 w-5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          ><path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 6h16M4 12h16M4 18h7"
          /></svg
        >
      </label>
      <!-- svelte-ignore a11y_no_noninteractive_tabindex -->
    </div>
  </div>
</div>

<div class="">
  {@render children?.()}
</div>

<!-- Spacer grows so the footer can be at bottom on short pages -->
<div class="flex-grow"></div>
<div class="">
  <!-- <div class="border-t max-w-[1000px] mx-auto"></div> -->
  <!-- <footer -->
  <!--   class="footer p-10 gap-x-48 lg:gap-x-64 xl:gap-x-96 place-content-center text-base" -->
  <!-- > -->
  <!-- <nav> -->
  <!--   <span class="footer-title opacity-80">Explore</span> -->
  <!--   <a class="link link-hover mb-1" href="/">Overview</a> -->
  <!--   <a class="link link-hover my-1" href="/pricing">Pricing</a> -->
  <!--   <a class="link link-hover my-1" href="/blog">Blog</a> -->
  <!--   <a class="link link-hover my-1" href="/contact_us">Contact Us</a> -->
  <!--   <a -->
  <!--     class="link link-hover my-1" -->
  <!--     href="https://github.com/CriticalMoments/CMSaasStarter">Github</a -->
  <!--   > -->
  <!-- </nav> -->
  <!-- <aside> -->
  <!--   <span class="footer-title opacity-80">Sponsor</span> -->
  <!--   <a class="max-w-[260px]" href="https://getkiln.ai"> -->
  <!--     <div class="font-bold text-3xl mb-1">Kiln AI</div> -->
  <!--     <div class="font-medium mb-3">Build High Quality AI Products</div> -->
  <!--     <div class="font-light"> -->
  <!--       Use advanced AI tactics, and collaborate with your team. Free apps for -->
  <!--       Mac and Windows. -->
  <!--     </div> -->
  <!--     <div class="link text-sm font-bold mt-2">Learn More</div> -->
  <!--   </a> -->
  <!-- </aside> -->
  <!-- </footer> -->
</div>
